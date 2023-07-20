function[sortedTaskList,varargout]=getTaskSortedLists(objectH,varargin)







































    origValue=slsvTestingHook('DisplayFullSortedInfo',1);
    slList=get_param(objectH,"SortedLists");
    slsvTestingHook('DisplayFullSortedInfo',origValue);


    allBlocks=vertcat(slList.SortedBlocks);
    if isempty(allBlocks)
        sortedTaskList=[];
    else

        exportFcnBlkIdx=startsWith({allBlocks.PortGroup},"F");
        expFcnBlkHandles=unique([allBlocks(exportFcnBlkIdx).BlockHandle]);

        if nargin>1&&isnumeric(varargin{1})

            taskID=varargin{1};
            slListIdx=[slList.TaskIndex]==taskID;
            sortedTaskList=slList(slListIdx);
            if isempty(sortedTaskList)||strcmpi(sortedTaskList.SampleTimes(1).Annotation,"Inf")




                otherConstantIdx=[slList.TaskIndex]==taskID+1;
                sortedTaskList=[sortedTaskList,slList(otherConstantIdx)];
                if numel(sortedTaskList)>1


                    sortedTaskList(1).SortedBlocks=combineConstantBlocks(...
                    sortedTaskList(1).SortedBlocks,sortedTaskList(2).SortedBlocks);
                    sortedTaskList(2)=[];
                end
            end



            if isempty(sortedTaskList)
                sortedTaskList=[];
            else


                sortedTaskList.SortedBlocks=removeExportFcnDataBlks(sortedTaskList.SortedBlocks,expFcnBlkHandles);
                if isempty(sortedTaskList.SortedBlocks)



                    sortedTaskList=[];
                else

                    sortedTaskList.SortedBlocks=addIsHiddenProp(sortedTaskList.SortedBlocks,false);
                end
            end
        else

            if slList(end).TaskIndex<0
                slList(end)=[];
            end



            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok



            modelH=bdroot(objectH);
            if nargin>1
                eoTable=varargin{1};
            else
                schedule=get_param(modelH,"Schedule");
                eoTable=schedule.Order;
            end


            if nargout>1
                varargout{1}=eoTable;
            end

            scheduleTasks=string(eoTable.Partition);





            tcg=sltp.TaskConnectivityGraph(modelH);
            idxMap=tcg.getCachedRateIndexTaskIdxMap();
            idxMapRateIndices=[idxMap.rateIdx];



            slOrderedIndices=[];

            nTasks=numel(scheduleTasks);
            slListTaskIDs=[slList.TaskIndex];
            for schedIdx=1:nTasks
                taskName=scheduleTasks(schedIdx);



                taskRateIdx=tcg.getRateDisplayIndex(taskName);
                mapEntry=idxMap(idxMapRateIndices==taskRateIdx);
                taskID=mapEntry.taskIdx;
                slIdx=find(slListTaskIDs==taskID);

                if~isempty(slIdx)


                    filteredSortedBlocks=removeExportFcnDataBlks(slList(slIdx).SortedBlocks,expFcnBlkHandles);



                    if~isempty(filteredSortedBlocks)
                        slList(slIdx).SortedBlocks=filteredSortedBlocks;

                        slList(slIdx).TaskName=taskName;
                        slList(slIdx).Type=string(eoTable{taskName,"Type"});
                        slList(slIdx).Trigger=eoTable{taskName,"Trigger"};
                        slList(slIdx).SourceBlock=getSourceBlock(modelH,taskName,slList(slIdx),tcg);
                        slList(slIdx).IsScheduleTask=true;
                        slList(slIdx).SortedBlocks=addIsHiddenProp(slList(slIdx).SortedBlocks,true);


                        slOrderedIndices(end+1)=slIdx;%#ok<AGROW>
                    end
                end
            end




            sortedTaskList=slList(slOrderedIndices);
            if isempty(sortedTaskList)




                sortedTaskList=[];
            end

            slList(slOrderedIndices)=[];





            nNonSchedTasks=numel(slList);
            if nNonSchedTasks>1
                secondLastTask=slList(end-1);
                if strcmpi(secondLastTask.SampleTimes(1).Annotation,"Inf")...
                    &&strcmpi(slList(end).SampleTimes(1).Annotation,"Inf")

                    secondLastTask.SortedBlocks=combineConstantBlocks(...
                    secondLastTask.SortedBlocks,slList(end).SortedBlocks);



                    slList(end-1)=secondLastTask;
                    slList(end)=[];
                    nNonSchedTasks=nNonSchedTasks-1;
                end
            end





            numWhitespacePat=whitespacePattern+asManyOfPattern(digitsPattern,1);


            for idx=1:nNonSchedTasks
                currTask=slList(idx);


                filteredSortedBlocks=removeExportFcnDataBlks(currTask.SortedBlocks,expFcnBlkHandles);



                if~isempty(filteredSortedBlocks)

                    taskName=string(currTask.SampleTimes(1).Annotation);
                    if strcmp(taskName,"Inf")
                        taskName="Constant";
                    end
                    taskType=string(currTask.SampleTimes(1).Description);

                    taskType=erase(taskType,numWhitespacePat);
                    sourceBlock=getSourceBlock(modelH,taskName,currTask,tcg);


                    currTask.TaskName=taskName;
                    currTask.Type=taskType;
                    currTask.Trigger="";
                    currTask.SourceBlock=sourceBlock;
                    currTask.IsScheduleTask=false;

                    currTask.SortedBlocks=addIsHiddenProp(currTask.SortedBlocks,true);

                    sortedTaskList=[sortedTaskList;currTask];%#ok<AGROW>
                end
            end
        end
    end
end

function srcBlockList=getSourceBlock(modelH,taskName,taskInfo,tcg)


    srcBlockList="";
    if tcg.hasTask(taskName)

        srcSID=tcg.getSourceBlockSIDs(taskName);
        nSrc=numel(srcSID);

        for k=1:nSrc
            sidNum=srcSID{k};
            sid=strcat(getfullname(modelH),":",sidNum);
            srcBlockList(k)=string(getfullname(sid));
        end
    else
        taskST=taskInfo.SampleTimes;



        if isscalar(taskST)
            modelST=Simulink.BlockDiagram.getSampleTimes(modelH);
            stIdx=strcmp({modelST.Description},taskST.Description);
            if any(stIdx)&&~isempty(modelST(stIdx).OwnerBlock)
                srcBlockList=string(modelST(stIdx).OwnerBlock);
            end
        end
    end
end

function uniqueBlocks=combineConstantBlocks(list1,list2)



    allConstBlocks=[list1;list2];

    [~,uniqueIdx,~]=unique([allConstBlocks.BlockHandle],"Stable");
    uniqueBlocks=allConstBlocks(uniqueIdx);



    allConstBlocks(uniqueIdx)=[];
    nDupBlocks=numel(allConstBlocks);
    for dupBlkIdx=1:nDupBlocks
        dupBlock=allConstBlocks(dupBlkIdx);
        keepBlockIdx=([uniqueBlocks.BlockHandle]==dupBlock.BlockHandle);
        keepBlock=uniqueBlocks(keepBlockIdx);
        keepBlock.InputPorts=unique([keepBlock.InputPorts,dupBlock.InputPorts]);
        keepBlock.OutputPorts=unique([keepBlock.OutputPorts,dupBlock.OutputPorts]);
        uniqueBlocks(keepBlockIdx)=keepBlock;
    end
end

function newSortedBlocks=removeExportFcnDataBlks(blkList,expFcnBlkHandles)
    toRemove=arrayfun(...
    @(x)ismember(x.BlockHandle,expFcnBlkHandles)&&~startsWith(x.PortGroup,"F"),blkList);

    newSortedBlocks=blkList(~toRemove);
end

function blkList=addIsHiddenProp(blkList,isEngineInterfaceEnabled)


    nBlocks=numel(blkList);
    blkHandles=getSimulinkBlockHandle({blkList.BlockPath});
    validBlksIdx=blkHandles~=-1;
    isHiddenArray=true(nBlocks,1);
    if any(validBlksIdx)
        isHiddenArray(validBlksIdx)=slreportgen.utils.internal.isHiddenBlock(...
        blkHandles(validBlksIdx),isEngineInterfaceEnabled);
    end
    isHiddenArray=num2cell(isHiddenArray);
    [blkList.IsHidden]=isHiddenArray{:};

end