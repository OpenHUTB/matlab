classdef FindAsyncManager<handle

    properties(Constant)
        annoType=0;
        blockType=1;
        blockDlgParamType=2;
        matlabFunctionType=3;
        signalType=4;
        sfObjectType=5;

        allSlBlks=10;
        allSfCharts=11;
    end


    properties(Access=private)


        findTasksList=[];
        findSfTaskQueue=[];
        currentTaskInfo=struct();


        executedTasks=[];


        processorTasksList=StructArrayList([]);


        findProgressListener;
        findCompletionListener;


        annoH=[];
        blkH_all=[];
        portH=[];

        blkH=[];
        blkH_dialogParams=[];
        blkH_matlabFunction=[];

        sfObjId=[];

        isProcessingCurrentTask=false;



        asyncProcessFunctionManager;


        slBlkDialogParamChunkSize=1;
        slChunkSize=100;
        sfChunkSize=1;


        taskNumToExecuteBeforeCancel=-1;
        isFinderRunningInTest=false;


        searchId;


        timeEachProcess=0.04;
        numChunksEachProcess=2;
        initChunkFactor=0.5;
        currentProcessFactor=0.75;

        processedResults=[];
        resultNumToPublish=200;
    end

    properties
        searchFailed=false;
        allSearchFinished=false;
        isCancelled=false;



        imStop=false;

        isUpdatingUI=false;
        addedNewResults=false;
    end

    methods

        function obj=FindAsyncManager(progressHandle,completionHandle,findId)
            obj.findProgressListener=progressHandle;
            obj.findCompletionListener=completionHandle;
            obj.asyncProcessFunctionManager=dastudio_util.cooperative.AsyncFunctionRepeaterTask;
            obj.searchId=findId;
            obj.processorTasksList=StructArrayList([]);
        end

        function startAsyncFind(obj)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::startAsyncFind");
            obj.resetReslts()
            obj.startNextTask();
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::startAsyncFind");
        end

        function resetReslts(obj)

            obj.annoH=[];
            obj.blkH_all=[];
            obj.portH=[];

            obj.blkH=[];
            obj.blkH_dialogParams=[];
            obj.blkH_matlabFunction=[];

            obj.sfObjId=[];

            obj.allSearchFinished=false;

            obj.searchFailed=false;
        end

        function resultH=getResultHandles(obj,objectType)
            if objectType==obj.annoType
                resultH=obj.annoH;
            elseif objectType==obj.blockType
                resultH=obj.blkH_all;
            elseif objectType==obj.blockDlgParamType
                resultH=obj.blkH_dialogParams;
            elseif objectType==obj.matlabFunctionType
                resultH=obj.blkH_matlabFunction;
            elseif objectType==obj.signalType
                resultH=obj.portH;
            elseif objectType==obj.sfObjectType
                resultH=obj.sfObjId;
            end

        end

        function addNewResults(obj,newResultH,objectType)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::addNewResults");

            if objectType==obj.annoType
                obj.annoH=[obj.annoH;newResultH];
            elseif objectType==obj.blockType
                obj.blkH=[obj.blkH;newResultH];
                obj.blkH_all=unique([obj.blkH;newResultH],'stable');
            elseif objectType==obj.blockDlgParamType
                obj.blkH_dialogParams=[obj.blkH_dialogParams;newResultH];
                obj.blkH_all=unique([obj.blkH;newResultH],'stable');
            elseif objectType==obj.matlabFunctionType
                obj.blkH_matlabFunction=[obj.blkH_matlabFunction;newResultH];
                obj.blkH_all=unique([obj.blkH;newResultH],'stable');
            elseif objectType==obj.signalType
                obj.portH=[obj.portH;newResultH];
            elseif objectType==obj.sfObjectType
                obj.sfObjId=[obj.sfObjId;newResultH];
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::addNewResults");
        end


        function cancelFind(obj,~,~)
            obj.isCancelled=true;

            if isfield(obj.currentTaskInfo,'isAsync')&&obj.currentTaskInfo.isAsync
                task=obj.currentTaskInfo.result;
                if task.Status==simulink.FindSystemTask.Status.Running
                    task.cancel();
                end
            end
        end


        function imStopFind(obj)
            obj.cancelFind();


            if strcmp(obj.asyncProcessFunctionManager.Status,'Running')
                obj.asyncProcessFunctionManager.stop();
            end

            obj.imStop=true;
        end


        function cancelled=isFindCancelled(obj)
            cancelled=obj.isCancelled;
        end


        function startNextTask(obj)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::startNextTask");
            if isempty(obj.findTasksList)&&~isempty(obj.findSfTaskQueue)
                obj.findTasksList=obj.findSfTaskQueue;
                obj.findSfTaskQueue=[];
            end

            if~obj.isFindCancelled()...
                &&~isempty(obj.findTasksList)...
                &&~obj.searchFailed

                obj.currentTaskInfo=obj.findTasksList(1);
                obj.findTasksList(1)=[];

                obj.executedTasks=[obj.executedTasks;obj.currentTaskInfo];

                obj.isProcessingCurrentTask=true;

                if obj.currentTaskInfo.isAsync

                    obj.currentTaskInfo.result.start('OnProgress',@(task,numTotal,numNew)(obj.asyncFindProgressListener(task,numTotal,numNew)),...
                    'OnComplete',@(task)(obj.asyncFindCompleteListener(task)),'OnCancel',@(task)(obj.asyncFindCompleteListener(task)),...
                    'OnError',@(task,err)(obj.asyncFindErrorListener(task,err)));
                else
                    try

                        objType=obj.currentTaskInfo.searchType;


                        obj.addProcessorTask(obj.currentTaskInfo.result,objType)


                        obj.startProcessFuncManager();


                        obj.isProcessingCurrentTask=false;
                    catch
                        obj.findSearchFailed();
                    end
                end
            else
                obj.allAsyncFindFinished();
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::startNextTask");
        end


        function asyncFindProgressListener(obj,task,numTotal,numNew)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::asyncFindProgressListener");
            if~obj.isFindCancelled()


                resultsH=task.results();

                if iscell(resultsH)
                    resultsH=[resultsH{:}]';
                end


                newResultsH=resultsH(numTotal-numNew+1:numTotal);
                objType=obj.currentTaskInfo.searchType;

                if(objType==obj.allSlBlks||objType==obj.allSfCharts)

                    obj.currentTaskInfo.progressListener(newResultsH);
                else
                    if slfeature('FindSystemSupportForReturningPropMatches')>0&&...
                        isstruct(resultsH)


                        existingResultList=obj.getResultHandles(objType);
                        if~isempty(newResultsH)&&~isempty(existingResultList)
                            invalidHdls=ismember([newResultsH.handle],existingResultList);
                            newResultsH=newResultsH(~invalidHdls);
                        end

                        obj.addProcessorTask(newResultsH,objType);
                        obj.startProcessFuncManager();
                    else

                        newResultsH=unique(newResultsH,'stable');
                        resultList=obj.getResultHandles(objType);
                        newResultsH=obj.removeDuplicateElement(newResultsH,resultList);


                        obj.addProcessorTask(newResultsH,objType)



                        obj.startProcessFuncManager();
                    end
                end
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::asyncFindProgressListener");
        end


        function asyncFindCompleteListener(obj,~)
            obj.completeCurrentTask();
        end

        function asyncFindErrorListener(obj,~,~)
            obj.findSearchFailed();
        end


        function asyncFindCancelListener(obj,~)
            obj.isProcessingCurrentTask=false;
            obj.allAsyncFindFinished();
        end

        function completeCurrentTask(obj)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::completeCurrentTask");
            obj.isProcessingCurrentTask=false;

            if obj.isFindCancelled()
                obj.allAsyncFindFinished();
            else
                if obj.processorTasksList.isempty()

                    processResultStatus=obj.asyncProcessFunctionManager.Status;
                    if strcmp(processResultStatus,'Running')
                        obj.asyncProcessFunctionManager.pause();
                    end

                    if obj.isFinderRunningInTest&&obj.shouldAutoCancel()
                        obj.cancelFind();
                    end
                    obj.startNextTask();
                end
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::completeCurrentTask");
        end

        function findSearchFailed(obj)
            obj.searchFailed=true;
            obj.findCompletionListener(obj.searchId);
        end


        function addTask(obj,newTaskInfo)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::addTask");
            if(~isempty(newTaskInfo.result))
                if(newTaskInfo.searchType==obj.sfObjectType)
                    obj.findSfTaskQueue=[obj.findSfTaskQueue;newTaskInfo];
                else
                    obj.findTasksList=[obj.findTasksList;newTaskInfo];
                end
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::addTask");
        end


        function addProcessorTask(obj,newResults,objectType)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::addProcessorTask");
            resultNum=length(newResults);
            if resultNum>0

                if objectType==obj.sfObjectType
                    processChunkSize=obj.sfChunkSize;
                elseif objectType==obj.blockDlgParamType
                    processChunkSize=obj.slBlkDialogParamChunkSize;
                else
                    processChunkSize=obj.slChunkSize;
                end

                remainingNum=resultNum;
                idx=0;
                while(remainingNum>0)


                    startIdx=idx*processChunkSize+1;
                    if(remainingNum<processChunkSize)
                        chunkResults=newResults(startIdx:end);
                    else
                        chunkResults=newResults(startIdx:startIdx+processChunkSize-1);
                    end


                    processTask=struct([]);
                    processTask(1).results=chunkResults;
                    processTask(1).objectType=objectType;
                    obj.processorTasksList.appendData(processTask);

                    idx=idx+1;
                    remainingNum=remainingNum-processChunkSize;
                end

            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::addProcessorTask");
        end


        function stopRepeating=processMoreResult(obj,~)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::processMoreResult");
            hasResultToProcess=false;



            shouldStopProcessing=obj.isFindCancelled()&&~obj.isFinderRunningInTest;


            if~shouldStopProcessing
                hasResultToProcess=~obj.processorTasksList.isempty();
                startingTime=tic;

                spentTime=0;
                timeExpired=false;
                processedChunks=0;
                numChunks=ceil(obj.numChunksEachProcess*obj.initChunkFactor);
                averageTimePerChunk=obj.timeEachProcess/obj.numChunksEachProcess;
                while(~timeExpired&&hasResultToProcess&&~shouldStopProcessing)

                    numChunks=min(numChunks,obj.processorTasksList.length());


                    if(numChunks>0)
                        for i=1:numChunks
                            currentResults=obj.processorTasksList(i);
                            obj.processResults(currentResults);
                        end

                        obj.processorTasksList(1:numChunks)=[];
                        processedChunks=processedChunks+numChunks;
                    end
                    hasResultToProcess=~obj.processorTasksList.isempty();
                    shouldStopProcessing=obj.isFindCancelled()&&~obj.isFinderRunningInTest;




                    spentTime=toc(startingTime);
                    timeExpired=spentTime>=obj.timeEachProcess;
                    if(~timeExpired&&hasResultToProcess&&processedChunks>0)

                        remainingTime=obj.timeEachProcess-spentTime;
                        numChunks=ceil(remainingTime/averageTimePerChunk);
                    end
                end



                if(processedChunks>0&&spentTime>0)
                    obj.numChunksEachProcess=ceil(obj.currentProcessFactor*(obj.timeEachProcess/(spentTime/processedChunks))...
                    +(1-obj.currentProcessFactor)*obj.numChunksEachProcess);
                end

            end

            if shouldStopProcessing||~hasResultToProcess
                processResultStatus=obj.asyncProcessFunctionManager.Status;
                if strcmp(processResultStatus,'Running')
                    obj.asyncProcessFunctionManager.pause();
                end



                if~(obj.currentTaskInfo.isAsync&&obj.isProcessingCurrentTask)
                    obj.completeCurrentTask();
                end
            end

            stopRepeating=false;
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::processMoreResult");
        end


        function returnList=removeDuplicateElement(~,newList,existList)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::removeDuplicateElement");
            newListUniq=unique(newList,'stable');
            if~isempty(newListUniq)&&~isempty(existList)
                ismemIdx=ismember(newListUniq,existList);
                returnList=newListUniq(~ismemIdx);
            else
                returnList=newListUniq;
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::removeDuplicateElement");
        end


        function processResults(obj,rawResults)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::processResults");
            newResultsH=rawResults.results;
            objectType=rawResults.objectType;

            newResults=obj.currentTaskInfo.progressListener(newResultsH);



            if~isempty(newResults)&&objectType==obj.sfObjectType
                newSfId=[newResults.Handle]';
                sfIdList=obj.getResultHandles(objectType);
                newValidSfId=obj.removeDuplicateElement(newSfId,sfIdList);


                newResults(~ismember(newSfId,newValidSfId))=[];
            end

            if~isempty(newResults)

                newH=unique([newResults.Handle]');
                obj.addNewResults(newH,objectType);

                resultsList=struct([]);
                resultsList(1).results=newResults;
                resultsList(1).objectType=objectType;




                if isempty(obj.processedResults)
                    obj.processedResults=resultsList;
                else
                    numOfNewResults=numel(resultsList);
                    for i=1:numOfNewResults
                        obj.processedResults(end+1)=resultsList(i);
                    end
                end
                if~obj.isUpdatingUI
                    obj.updateUI();
                end
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::processResults");
        end


        function startProcessFuncManager(obj)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::startProcessFuncManager");
            processResultStatus=obj.asyncProcessFunctionManager.Status;
            if strcmp(processResultStatus,'Created')
                obj.asyncProcessFunctionManager.start(@(task)(obj.processMoreResult(task)),...
                'OnError',@(task,err)(obj.asyncFindErrorListener(task,err)));
            elseif strcmp(processResultStatus,'Paused')
                obj.asyncProcessFunctionManager.resume();
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::startProcessFuncManager");
        end


        function finishPreviousProcessing(obj)
            obj.processMoreResult();
        end


        function finishUpdatingUI(obj)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::finishUpdatingUI");
            if~obj.imStop
                if obj.isFindCancelled()
                    obj.processedResults=[];
                end

                if~isempty(obj.processedResults)
                    obj.updateUI();
                else
                    obj.isUpdatingUI=false;

                    if obj.allSearchFinished
                        obj.allFindComplete();
                    end
                end
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::finishUpdatingUI");
        end


        function allAsyncFindFinished(obj)
            if~obj.imStop
                obj.allSearchFinished=true;

                if~obj.isUpdatingUI&&isempty(obj.processedResults)
                    obj.allFindComplete();
                end
            end
        end


        function allFindComplete(obj)
            try
                obj.findCompletionListener(obj.searchId);
            catch

                obj.findSearchFailed();
            end
        end

        function updateUI(obj)
            obj.isUpdatingUI=true;

            resultsToPublish=obj.getNextResultsToPublish();
            obj.findProgressListener(resultsToPublish,obj.searchId);
        end

        function resultToPublish=getNextResultsToPublish(obj)
            simulink.FindSystemTask.Testing.startPerfRecordingFor("FindAsyncManager::getNextResultsToPublish");
            resultToPublish=[];
            resultNum=0;
            while(~isempty(obj.processedResults)&&resultNum<obj.resultNumToPublish)


                nextResult=obj.processedResults(1);
                if isempty(resultToPublish)
                    resultToPublish=nextResult;
                else
                    numOfNextResult=numel(nextResult);
                    for i=1:numOfNextResult
                        resultToPublish(end+1)=nextResult(i);
                    end
                end
                resultNum=resultNum+length(nextResult.results);

                obj.processedResults(1)=[];
            end
            simulink.FindSystemTask.Testing.stopPerfRecordingFor("FindAsyncManager::getNextResultsToPublish");
        end




        function allTasks=getAllTasks(obj)
            allTasks=[obj.findTasksList;obj.findSfTaskQueue;obj.executedTasks];
        end

        function executedTasks=getExecutedTasks(obj)
            executedTasks=obj.executedTasks;
        end

        function cancelFindAfterNumOfTasks(obj,num)
            obj.isFinderRunningInTest=true;
            obj.taskNumToExecuteBeforeCancel=num;
        end

        function cancel=shouldAutoCancel(obj)
            if obj.taskNumToExecuteBeforeCancel>-1
                executedTaskNum=length(obj.executedTasks);
                if executedTaskNum>=obj.taskNumToExecuteBeforeCancel
                    cancel=true;
                else
                    cancel=false;
                end
            end
        end

    end

end
