





















classdef Analyzer<handle

    properties(Access=private)
        mAnalysisStatus Sldv.AnalysisStatus;
        mResultFileNames=Sldv.Utils.initDVResultStruct();
        mAnalysisErrorMsg=[];
        mStrategy=0;
        mSearchDepth=0;
        mTimeLimit=0.0;
        mAnalysisTimer=[];
        mTimeOutListener=[];
        mAnalysisStartTime=0.0;
        mEnabledGoals=[];
        mAsyncAnalysisDone=false;
        mAsyncAnalysisFinished=false;
        mResultsUpdateAvailable=false;
        mTaskQueue=[];
        mResultStream=[];
        mTaskingFF=0;
    end

    properties(Access=private)
        mModelH=[];
        mBlockH=[];
        mBlockPathObj=[];
        mSldvOpts=[];
        mShowUI=false;
        mInitCovData=[];
        mTestComp=[];




        mSldvDataStaticCopy=[];
        mGoalToLinkinfoMap=[];
        mObjectiveToGoalMap=[];
        mGoalIdToObjectiveIdMap=[];
        mGoalIdToDvIdMap=[];









        setDefaultsToDontCareValues=true;
        defaultsAtUnusedInports=[];
    end

    events(NotifyAccess=private)
        AnalysisInit;
        AsyncAnalysisLaunched;
        AsyncAnalysisUpdate;
        AsyncAnalysisDone;
        TerminateAsyncAnalysis;
    end
    events(NotifyAccess=public)
        AnalysisWrap;
    end

    methods(Access=public)

        function[status,msg]=loadExistingTestCases(obj)
            status=1;
            msg=[];

            testComp=obj.mTestComp;


            isExtendingTestsFromFile=strcmp(testComp.activeSettings.Mode,'TestGeneration')&&...
            strcmp(testComp.activeSettings.ExtendExistingTests,'on');


            isExtendingTestsFromSimulation=strcmp(testComp.activeSettings.Mode,'TestGeneration')&&...
            strcmp(testComp.activeSettings.ExtendUsingSimulation,'on');

            if testComp.recordDvirSim||isExtendingTestsFromFile||isExtendingTestsFromSimulation

                obj.logDate;

                testComp.profileStage('Design Verifier: TestCase Loading');
                testComp.getMainProfileLogger().openPhase('Design Verifier: TestCase Loading');



                if isExtendingTestsFromSimulation

                    topModelName=get_param(obj.mModelH,'Name');
                    obj.logAll(getString(message('Sldv:Setup:Simulating',topModelName)));
                    [status,mex]=obj.simulateTopModelAndLoadTestCases();


                    defaultErrID='Sldv:Setup:SimulationFailed';
                    errMsg=getString(message(defaultErrID));
                else

                    obj.logAll(getString(message('Sldv:SldvRun:LoadingInitialTestData')));
                    [status,mex]=obj.loadTestCases(testComp.activeSettings.ExistingTestFile);


                    defaultErrID='Sldv:SldvRun:ErrorReadingExternalData';
                    errMsg=getString(message('Sldv:SldvRun:ErrorReadingTestData'));
                end

                testComp.profileStage('end');
                testComp.getMainProfileLogger().closePhase('Design Verifier: TestCase Loading');

                if~status
                    if~isempty(mex)
                        if strfind(mex.identifier,'Sldv:SldvRun:')
                            errMsg=[errMsg,' ',mex.message];
                            errorId=mex.identifier;
                        else
                            errMsg=strrep(sprintf('%s: %s',errMsg,mex.message),newline,' ');
                            errorId=defaultErrID;
                        end
                    else
                        errorId=defaultErrID;
                        errMsg=getString(message(errorId,testComp.activeSettings.ExistingTestFile));
                    end
                    sldvshareprivate('avtcgirunsupcollect','push',...
                    testComp.analysisInfo.analyzedModelH,'sldv',errMsg,errorId);
                    obj.logNewLines(errMsg);



                    obj.mAnalysisErrorMsg=obj.displayMessages();
                    msg=obj.mAnalysisErrorMsg;
                else
                    obj.logAll(sprintf('%s\n',getString(message('Sldv:Setup:Done'))));
                end
            end

            return;
        end

        [status,msg]=initAnalysis(obj);

        function[sldvData,...
            objectiveToGoalMap,...
            goalIdToObjectiveIdMap,...
            goalToLinkinfoMap,...
            goalIdToDvIdMap]=getStaticSldvData(obj)
            sldvData=obj.mSldvDataStaticCopy;
            objectiveToGoalMap=obj.mObjectiveToGoalMap;
            goalIdToObjectiveIdMap=obj.mGoalIdToObjectiveIdMap;
            goalToLinkinfoMap=obj.mGoalToLinkinfoMap;
            goalIdToDvIdMap=obj.mGoalIdToDvIdMap;
        end



        function status=setAnalysisOptions(obj,analysisOptions)
            assert(~isempty(obj.mTestComp));
            status=true;

            try
                optionNames=keys(analysisOptions);


                cellfun(@(opt)set(obj.mTestComp.activeSettings,opt,...
                analysisOptions(opt)),optionNames);
            catch MEx
                status=false;
            end

            return;
        end


        function options=getSldvOptions(obj)
            options=obj.mSldvOpts;

            return;
        end


        function taskQueue=getTaskQueue(obj)
            taskQueue=obj.mTaskQueue;
        end



        function resultStream=getResultStream(obj)
            resultStream=obj.mResultStream;
        end

        function resultStreamId=getResultStreamId(obj)
            resultStreamId='';
            if~isempty(obj.mResultStream)
                resultStreamId=obj.mResultStream.getResultStreamId();
            end
        end

        function taskQueueId=getTaskQueueId(obj)
            taskQueueId='';
            if~isempty(obj.mTaskQueue)
                taskQueueId=obj.mTaskQueue.getTaskQueueId();
            end
        end





        function status=updateAnalysisOptions(obj,sldvOptions)
            assert(strcmp(sldvOptions.Mode,obj.mSldvOpts.Mode));
            assert(~isempty(obj.mTestComp));

            testComp=obj.mTestComp;

            status=true;

            if slfeature('SldvDeprecateDisplayUnsatisfiableObjectives')
                genAnalysisOptions={'MaxProcessTime',...
                'OutputDir'};
            else
                genAnalysisOptions={'MaxProcessTime',...
                'DisplayUnsatisfiableObjectives',...
                'OutputDir'};
            end
            testGenAnalysisOptions={'TestSuiteOptimization',...
            'MaxTestCaseSteps',...
'ExtendExistingTests'...
            ,'ExistingTestFile',...
            'IgnoreExistTestSatisfied',...
            'SaveExpectedOutput',...
            'RandomizeNoEffectData'};


            dedAnalysisOptions={};
            propProvingAnalysisOptions={'ProvingStrategy',...
            'MaxViolationSteps'};
            resultOptions={'SaveDataFile',...
            'DataFileName'};
            testGenResultOptions={'SaveHarnessModel',...
            'HarnessModelFileName',...
            'ModelReferenceHarness',...
            'SlTestFileName',...
            'SlTestHarnessName'};
            reportOptions={'SaveReport',...
            'ReportPDFFormat',...
            'ReportFileName',...
            'ReportIncludeGraphics',...
            'DisplayReport',...
            'DisplayResultsOnModel'};


            cellfun(@(opt)set(testComp.activeSettings,opt,get(sldvOptions,opt)),...
            genAnalysisOptions);


            if(strcmp('TestGeneration',obj.mSldvOpts.Mode))
                cellfun(@(opt)set(testComp.activeSettings,opt,get(sldvOptions,opt)),...
                testGenAnalysisOptions);
                cellfun(@(opt)set(testComp.activeSettings,opt,get(sldvOptions,opt)),...
                testGenResultOptions);
            elseif(strcmp('DesignErrorDetection',obj.mSldvOpts.Mode))
                cellfun(@(opt)set(testComp.activeSettings,opt,get(sldvOptions,opt)),...
                dedAnalysisOptions);
            elseif(strcmp('PropertyProving',obj.mSldvOpts.Mode))
                cellfun(@(opt)set(testComp.activeSettings,opt,get(sldvOptions,opt)),...
                propProvingAnalysisOptions);
            end


            cellfun(@(opt)set(testComp.activeSettings,opt,get(sldvOptions,opt)),...
            resultOptions);


            cellfun(@(opt)set(testComp.activeSettings,opt,get(sldvOptions,opt)),...
            reportOptions);

            return;
        end




        function enabledGoals=setAnalysisGoals(obj,goals)
            testComp=obj.mTestComp;


            enabledGoals=testComp.enableGoals(goals);


            allGoals=testComp.getAllGoalIds();
            goalsToDisable=setdiff(allGoals,enabledGoals);
            testComp.disableGoals(goalsToDisable);

            return;
        end

        [status,msg,resultFileNames]=runAnalysis(obj,analysisInput);

        [status,msg]=runAnalysisAsync(obj,analysisInput);



        function done=isAnalysisDone(obj)
            done=obj.mTestComp.isAnalysisDone();
            obj.mAsyncAnalysisDone=done;
        end

        function results=getAnalysisResults(obj)

            obj.readAnalysisResults();


            results=obj.popIncrementalResults();





            obj.mResultsUpdateAvailable=false;

            return;
        end




        function terminateAsyncAnalysis(obj,notifyOnTerminate,cause)
            assert(~isempty(obj.mTestComp));
            testComp=obj.mTestComp;

            if(nargin<3)

                cause='DV_CAUSE_INTERRUPTED';
            end
            if(strcmp(testComp.analysisStatus,'In progress'))




                terminationStatus=testComp.terminateAnalysis(notifyOnTerminate,cause);
                if(false==notifyOnTerminate)
                    obj.mAnalysisStatus=obj.processBackendAnalysisStatus(terminationStatus);

                    obj.postAnalysis();
                end
            end

            return;
        end

        function wrapAnalysis(obj,analysisStatus)


            slavteng('feature','BitPreciseAnalysis',0);
            slavteng('feature','FloatPtOvf',0);
            slavteng('feature','SubnormalChk',0);


            testComp=obj.mTestComp;
            if sldvprivate("isTaskingArchitectureEnabled")
                if~isempty(obj.mTaskQueue)
                    obj.mTaskQueue.cleanUp();
                end
                if~isempty(obj.mResultStream)
                    obj.mResultStream.cleanUp();
                end
            end

            testComp.profileStage('end');
            testComp.getMainProfileLogger().closePhase('Design Verifier: Analysis');






            if(Sldv.AnalysisStatus.None==obj.mAnalysisStatus)
                return;
            end



            if(Sldv.AnalysisStatus.WaitingForInit~=obj.mAnalysisStatus)


                testComp.activeSettings=obj.deepCopyAnalysisOptions();



                obj.restoreAnalysisGoals();


                testComp.wrapAnalysis();


                results=popIncrementalResults(obj);

                isValidatorON=Sldv.Utils.isValidatorEnabled(obj.mSldvOpts,testComp.simMode);

                goalCnt=length(results.goals);

                if goalCnt>0






                    firstGoal=testComp.getGoal(1);


                    goalUDIs=firstGoal;
                    goalUDIs(1:goalCnt)=firstGoal;

                    if isValidatorON
                        force=false;
                        tcIdx=0;
                        for num=1:goalCnt
                            goalId=results.goals(num);
                            goalUDI=testComp.getGoal(goalId);
                            goalUDIs(num)=goalUDI;
                            status=goalUDI.status;
                            testComp.updateValidatedGoals(goalId,string(status),force,tcIdx);
                        end
                    else
                        for num=1:goalCnt
                            goalId=results.goals(num);
                            goalUDI=testComp.getGoal(goalId);
                            goalUDIs(num)=goalUDI;
                        end
                    end

                else
                    goalUDIs=[];
                end

                slavteng_result_callback(testComp,goalUDIs);
                jnk=[];
                slavteng_activity_callback(testComp,jnk);




                obj.recordErroredObjectives();
            end




            elapsedTime=testComp.getElapsedTime();
            userTimeOut=obj.mSldvOpts.MaxProcessTime;



            if(Sldv.AnalysisStatus.WaitingForInit==obj.mAnalysisStatus)
                obj.mAnalysisStatus=Sldv.AnalysisStatus.Failure;



            elseif(Sldv.AnalysisStatus.None~=analysisStatus)
                obj.mAnalysisStatus=analysisStatus;
            elseif(Sldv.AnalysisStatus.Timeout==obj.mAnalysisStatus)&&...
                (elapsedTime<userTimeOut)























                obj.mAnalysisStatus=Sldv.AnalysisStatus.Success;
            end

            testComp.analysisStatus=obj.getAnalysisStatusStr();

            obj.logAnalysisCompletionMessage();
            obj.checkAndReportTimeOut();

            analysisProgressUI=testComp.progressUI;
            slfeature('SldvTaskingArchitecture',obj.mTaskingFF);

            if obj.mShowUI

                analysisInProgress=false;
                analysisProgressUI.setAnalysisStatus(analysisInProgress);

                analysisProgressUI.setElapsedTimerMode(analysisInProgress);

                analysisProgressUI.refreshLogArea();
            end

            if(Sldv.AnalysisStatus.LaunchFailed==obj.mAnalysisStatus)||...
                (Sldv.AnalysisStatus.Failure==obj.mAnalysisStatus)

                analysisError=getString(message('Sldv:SldvRun:ErrorDuringAnalysis',...
                obj.getAnalysisStatusStr()));

                sldvshareprivate('avtcgirunsupcollect','push',...
                testComp.analysisInfo.analyzedModelH,...
                'simulink',analysisError,'Sldv:SldvRun:ErrorDuringAnalysis');

                if obj.mShowUI
                    analysisProgressUI.finalized=true;
                    analysisProgressUI.refreshLogArea();
                end


                obj.mAnalysisErrorMsg=obj.displayMessages();
            end

            return;
        end


        function status=getCurrentAnalysisStatus(obj)
            status=obj.mAnalysisStatus;
        end










        function analysisStatusStr=getAnalysisStatusStr(obj)
            analysisStatusStr='';
            if(Sldv.AnalysisStatus.LaunchFailed==obj.mAnalysisStatus)
                analysisStatusStr='Analysis launch failed';





            elseif(Sldv.AnalysisStatus.Success==obj.mAnalysisStatus)||...
                (Sldv.AnalysisStatus.OutOfMemory==obj.mAnalysisStatus)||...
                (Sldv.AnalysisStatus.ContradictoryModel==obj.mAnalysisStatus)
                analysisStatusStr='Completed normally';
            elseif(Sldv.AnalysisStatus.Terminated==obj.mAnalysisStatus)
                analysisStatusStr='Stopped by user';
            elseif(Sldv.AnalysisStatus.Timeout==obj.mAnalysisStatus)
                analysisStatusStr='Exceeded time limit';
            elseif(Sldv.AnalysisStatus.Running==obj.mAnalysisStatus)
                analysisStatusStr='In progress';
            else
                analysisStatusStr='Stopped due to errors';
            end

            return;
        end





        function status=getAnalysisStatus(obj)
            status=0;



            if(Sldv.AnalysisStatus.Success==obj.mAnalysisStatus)||...
                (Sldv.AnalysisStatus.Terminated==obj.mAnalysisStatus)||...
                (Sldv.AnalysisStatus.OutOfMemory==obj.mAnalysisStatus)||...
                (Sldv.AnalysisStatus.ContradictoryModel==obj.mAnalysisStatus)
                status=1;
            elseif(Sldv.AnalysisStatus.Timeout==obj.mAnalysisStatus)
                status=-1;
            else
                status=0;
            end

            return;
        end

        function resultFileNames=getResultFileNames(obj)
            resultFileNames=obj.mResultFileNames;

            return;
        end

        function analysisErrMsg=getAnalysisErrorMsg(obj)
            analysisErrMsg=obj.mAnalysisErrorMsg;

            return;
        end


        [status,msg,resultFileNames,sldvData]=generateResults(obj);

    end



    methods(Access=private)
        function options=deepCopyAnalysisOptions(obj)
            options=obj.mSldvOpts.deepCopy();


            options.ObservabilityCustomization=obj.mSldvOpts.ObservabilityCustomization;
            options.DetectDSMAccessViolations=obj.mSldvOpts.DetectDSMAccessViolations;
            options.DetectBlockInputRangeViolations=obj.mSldvOpts.DetectBlockInputRangeViolations;
            return;
        end

        function cacheEnabledGoals(obj)

            obj.mEnabledGoals=[];
            testComp=obj.mTestComp;


            allGoals=testComp.getAllGoalIds();
            for goalNo=1:length(allGoals)
                goalId=allGoals(goalNo);
                goal=testComp.getGoal(goalId);
                status=goal.isEnabled();
                if(true==status)
                    obj.mEnabledGoals(end+1)=goalId;
                end
            end
        end

        function cacheStaticSldvData(obj)









            [obj.mSldvDataStaticCopy,...
            obj.mObjectiveToGoalMap,...
            obj.mGoalIdToObjectiveIdMap,...
            ~,...
            obj.mGoalToLinkinfoMap,...
            obj.mGoalIdToDvIdMap]=Sldv.DataUtils.save_data(...
            obj.mTestComp.analysisInfo.analyzedModelH,obj.mTestComp);
        end


        function status=restoreAnalysisGoals(obj)
            testComp=obj.mTestComp;


            testComp.enableGoals(obj.mEnabledGoals);


            allGoals=testComp.getAllGoalIds();
            disabledGoals=setdiff(allGoals,obj.mEnabledGoals);


            testComp.disableGoals(disabledGoals);

            status=true;
        end


        function readStatus=readAnalysisResults(obj)
            readStatus=obj.mTestComp.readAnalysisResults();

            return;
        end

        function results=popIncrementalResults(obj)
            results=obj.mTestComp.popIncrementalResults();
            obj.updateDontCareValuesForTestCases(results.testcases);
        end

        function updateDontCareValuesForTestCases(obj,tcIds)
            testComp=obj.mTestComp;

            if obj.setDefaultsToDontCareValues
                for ind=1:numel(tcIds)
                    tcId=tcIds(ind);
                    tc=testComp.getTestCase(tcId);
                    Sldv.DataUtils.updateDontCareValues(tc,obj.defaultsAtUnusedInports,obj.mSldvDataStaticCopy);
                end
            end
        end

        function initializeDefaultsAtUnusedInports(obj)





            if strcmpi('off',obj.mSldvOpts.DesignMinMaxConstraints)
                obj.setDefaultsToDontCareValues=false;
                return;
            end

            try
                [~,~,anyUnused]=Sldv.DataUtils.getInportUsage(obj.mSldvDataStaticCopy);
                if~anyUnused
                    obj.setDefaultsToDontCareValues=false;
                    return;
                end

                [obj.setDefaultsToDontCareValues,obj.defaultsAtUnusedInports]=...
                Sldv.DataUtils.getDefaultValuesForUnusedInports(obj.mSldvDataStaticCopy);
                if isempty(obj.defaultsAtUnusedInports)
                    obj.setDefaultsToDontCareValues=false;
                end
            catch



                obj.setDefaultsToDontCareValues=false;

            end
        end
    end


    methods(Access={?Sldv.Tasking.HighlighterTask,...
        ?Sldv.Tasking.ResultsProcessorTask,...
        ?Sldv.Tasking.ValidatorTask})

        function status=isHighlightOn(obj)
            session=sldvprivate('sldvGetActiveSession',obj.mModelH);
            status=session.HighlightStatusFlag;
        end

        function progressUIHandle=getProgressUIHandle(obj)
            progressUIHandle=obj.mTestComp.progressUI;
        end

        function analysisMode=getAnalysisMode(obj)
            analysisMode=obj.mTestComp.activeSettings.Mode;
        end

        function analysisOpts=getAnalysisOpts(obj)
            analysisOpts=obj.mTestComp.activeSettings;
        end

        function simMode=getAnalysisSimMode(obj)
            simMode=obj.mTestComp.simMode;
        end
    end


    methods(Access={?Sldv.Tasking.HighlighterTask,?Sldv.Tasking.ResultsProcessorTask})
        function status=getGoalStatus(obj,goalId)

            status=obj.mTestComp.getGoal(goalId).status;

            return;
        end

        function type=getGoalType(obj,goalId)

            type=obj.mTestComp.getGoal(goalId).type;

            return;
        end

        function status=getObjectiveStatus(obj,goalId)

            goal=obj.mTestComp.getGoal(goalId);
            objectiveFactory=Sldv.ReportObjectiveFactory(obj.mSldvOpts);
            status=objectiveFactory.getObjectiveStatus(goal);

            return;
        end

    end






    methods(Access=public)


        function onAnalysisUpdate(obj,inputStream,evData)



























            if(false==obj.mResultsUpdateAvailable)&&inputStream.DataAvailable()




                obj.mResultsUpdateAvailable=true;
                notify(obj,'AsyncAnalysisUpdate');
            end

            return;
        end



        function onAnalysisDone(obj,asyncChannel)
            obj.mAsyncAnalysisDone=true;




            obj.mResultsUpdateAvailable=true;
            notify(obj,'AsyncAnalysisUpdate');










            notify(obj,'AsyncAnalysisDone');
        end


        function analysisStatus=finishAnalysis(obj)


            finishStatus=obj.mTestComp.finishAnalysis();
            obj.mAnalysisStatus=obj.processBackendAnalysisStatus(finishStatus);


            obj.postAnalysis();





            obj.mAsyncAnalysisFinished=true;


            analysisStatus=obj.mAnalysisStatus;

            return;
        end


        function status=isAsyncAnalysisDone(obj)
            status=obj.mAsyncAnalysisDone;

            return;
        end


        function status=isAsyncAnalysisFinished(obj)
            status=obj.mAsyncAnalysisFinished;

            return;
        end

    end


    methods(Access=private)

        function[status,mex]=simulateTopModelAndLoadTestCases(obj)
            mex=[];


            stopTime=get_param(obj.mModelH,'StopTime');
            if strcmpi(stopTime,'Inf')
                status=false;


                msgId='Sldv:Setup:SimulationStopTimeNotSupported';
                msg=getString(message(msgId,stopTime));
                mex=MException(msgId,msg);

                return;
            end

            refModel=get_param(obj.mBlockH,'ModelName');
            [status,mex]=sldvshareprivate('isSimBasedTestExtensionSupported',refModel);
            if~status
                return;
            end

            try

                loggedTC=sldvlogsignals(obj.mBlockPathObj);


                testCaseLoader=Sldv.TestCaseLoader(obj.mTestComp,obj.mModelH);
                status=testCaseLoader.loadTestCases(loggedTC);
            catch mex
                status=false;
            end
        end


        function[status,mex]=loadTestCases(obj,existingTestFiles)
            mex=[];

            try
                testCaseLoader=Sldv.TestCaseLoader(obj.mTestComp,obj.mModelH);
                status=testCaseLoader.loadTestCases(existingTestFiles);
            catch mex
                status=false;
            end
        end

        [status,msg]=preAnalysis(obj);

        function postAnalysis(obj)
            testComp=obj.mTestComp;


            if~isempty(obj.mAnalysisTimer)&&obj.mAnalysisTimer.isRunning
                stop(obj.mAnalysisTimer);
            end

            sldvprivate('sldvCleanAnalysis',testComp,obj.mShowUI);

            testComp.profileStage('end');
            testComp.getMainProfileLogger().closePhase(sldvprivate('sldv_get_strategy_name',testComp));

            return;
        end

        function analysisStatus=processBackendAnalysisStatus(~,backendAnalysisStatus)
            analysisStatus=Sldv.AnalysisStatus.Success;

            if~isempty(backendAnalysisStatus)
                if strcmpi(backendAnalysisStatus,'Analysis launch failed')
                    analysisStatus=Sldv.AnalysisStatus.LaunchFailed;
                elseif strcmpi(backendAnalysisStatus,'Analysis was interrupted')
                    analysisStatus=Sldv.AnalysisStatus.Terminated;
                elseif strcmpi(backendAnalysisStatus,'Analysis timed out')
                    analysisStatus=Sldv.AnalysisStatus.Timeout;
                elseif strcmpi(backendAnalysisStatus,'Analysis ran out of memory')
                    analysisStatus=Sldv.AnalysisStatus.OutOfMemory;
                elseif strcmpi(backendAnalysisStatus,'Model is contradictory')
                    analysisStatus=Sldv.AnalysisStatus.ContradictoryModel;
                elseif strcmpi(backendAnalysisStatus,'Analysis produced error')||...
                    strcmpi(backendAnalysisStatus,'Internal error')

                    analysisStatus=Sldv.AnalysisStatus.Failure;
                else

                    analysisStatus=Sldv.AnalysisStatus.Failure;
                end
            end

            return;
        end

        function waitForAnalysisDone(obj)





            while(false==obj.mAsyncAnalysisFinished)
                drawnow();

            end

            return;
        end

        function analysisTimerCB(obj,timer,eventData)

            elapsedTime=etime(clock,obj.mAnalysisStartTime);

            timeOut=elapsedTime>=obj.mTimeLimit;

            if timeOut

                if timer.isRunning
                    stop(timer);
                end



                cause='DV_CAUSE_TIMEOUT';
                notifyOnTerminate=true;
                obj.terminateAsyncAnalysis(notifyOnTerminate,cause);
            end
        end

        function clearResults(obj)



            handles=get_param(obj.mModelH,'AutoVerifyData');
            if isfield(handles,'res_dialog')
                res_dialog=handles.res_dialog;
                if~isempty(res_dialog)
                    try
                        res_dialog.delete();
                    catch Mex %#ok<NASGU>



                    end
                end
            end
            if isfield(handles,'analysisFilter')
                if slavteng('feature','MultiFilter')
                    filterExplorer=handles.analysisFilter;
                    if~isempty(filterExplorer)
                        try
                            Sldv.FilterExplorer.close(filterExplorer);
                        catch Mex %#ok<NASGU>
                        end
                    end
                else
                    filter=handles.analysisFilter;
                    if~isempty(filter)
                        try
                            filter.reset;
                            filter.delete;
                        catch Mex %#ok<NASGU>
                        end
                    end
                end
            end
        end

        function str=activity(obj)
            testComp=obj.mTestComp;

            if strcmp(testComp.activeSettings.Mode,'TestGeneration')
                str=getString(message('Sldv:SldvRun:TestGeneration'));
            elseif strcmp(testComp.activeSettings.Mode,'DesignErrorDetection')
                str=getString(message('Sldv:SldvRun:ErrorDetection'));
            else
                str=getString(message('Sldv:SldvRun:PropertyProving'));
            end
            if strcmp(testComp.activeSettings.RequirementsTableAnalysis,'on')
                str=getString(message('Sldv:SldvRun:RequirementsAnalysis'));
            end
        end

        function logActivity(obj)
            testComp=obj.mTestComp;

            if strcmp(testComp.activeSettings.Mode,'TestGeneration')
                obj.logAll(getString(message('Sldv:SldvRun:GeneratingTests')));
            elseif strcmp(testComp.activeSettings.Mode,'DesignErrorDetection')
                obj.logAll(getString(message('Sldv:SldvRun:DetectingDesignErrors')));
            else
                obj.logAll(getString(message('Sldv:SldvRun:ProvingProperties')));
            end
            obj.logSome(newline);
        end


        function logCompatTimestamp(obj)
            testComp=obj.mTestComp;


            timestamp=testComp.compatTimestamp;
            assert(~isempty(timestamp));

            msg='';
            switch testComp.activeSettings.Mode
            case 'TestGeneration'
                msg=getString(message('Sldv:SldvRun:UsingCompatibilityGeneratingTests',timestamp));
            case 'DesignErrorDetection'
                msg=getString(message('Sldv:SldvRun:UsingCompatibilityDetectingDesignErrors',timestamp));
            case 'PropertyProving'
                msg=getString(message('Sldv:SldvRun:UsingCompatibilityProvingProperties',timestamp));
            end
            if strcmp(testComp.activeSettings.RequirementsTableAnalysis,'on')
                msg=getString(message('Sldv:SldvRun:UsingCompatibilityAnalyzingRequirementsTable',timestamp));
            end
            obj.logAll(msg);
            obj.logSome(newline);
        end

        function checkAndReportTimeOut(obj)
            testComp=obj.mTestComp;


            if strcmpi(testComp.analysisStatus,'Exceeded time limit')
                msg=getString(message('Sldv:SldvRun:CanExtendTime'));

                if~obj.mShowUI&&~ModelAdvisor.isRunning
                    disp(msg);
                end



                sldvshareprivate('avtcgirunsupcollect','push',...
                testComp.analysisInfo.analyzedModelH,'simulink',...
                strrep(msg,newline,' '),'Sldv:SldvRun:CanExtendTime');
            end
        end

        function logAnalysisCompletionMessage(obj)
            testComp=obj.mTestComp;

            obj.logDate();

            if strcmpi(testComp.analysisStatus,'Analysis launch failed')
                obj.logNewLines(getString(message('Sldv:SldvRun:AnalysisLaunchFailed',obj.activity())));
            elseif strcmpi(testComp.analysisStatus,'Exceeded time limit')
                obj.logNewLines(getString(message('Sldv:SldvRun:ExceededTimeLimit',obj.activity())));
            elseif strcmpi(testComp.analysisStatus,'Stopped by user')
                obj.logNewLines(getString(message('Sldv:SldvRun:WasStopped',obj.activity())));
            elseif strcmpi(testComp.analysisStatus,'Stopped due to errors')
                obj.logNewLines(getString(message('Sldv:SldvRun:ProducedErrors',obj.activity())));
            else
                obj.logNewLines(getString(message('Sldv:KeyWords:CompletedNormallyp')));
            end
        end

        function logDate(obj)
            obj.logSome(sprintf('\n%s',datestr(now)));
            obj.logAll(newline);
        end

        function logNewLines(obj,str)
            obj.logAll(sprintf('\n%s\n',str));
        end

        function logAll(obj,str)

            obj.logger(obj.mTestComp,obj.mShowUI,true,str);
        end

        function logSome(obj,str)

            obj.logger(obj.mTestComp,obj.mShowUI,false,str);
        end

        function stopped=stopRequested(obj)
            stopped=false;
            testComp=obj.mTestComp;

            if obj.mShowUI&&~isempty(testComp)


                drawnow();





                if~isvalid(obj)
                    stopped=true;
                    MEx=MException('Sldv:Analyzer:invalidObj',...
                    'SLDV Analyzer is no longer valid');
                    throw(MEx);
                end



                try



                    stopped=true;
                    if(isa(testComp,'SlAvt.TestComponent')&&~isempty(testComp.progressUI))
                        analysisProgressUI=testComp.progressUI;
                        stopped=analysisProgressUI.stopped;

                        if stopped&&~analysisProgressUI.finalized
                            obj.logNewLines(getString(message('Sldv:SldvRun:DVWasStopped')));
                            analysisProgressUI.finalized=true;
                            analysisProgressUI.refreshLogArea();
                            analysisProgressUI.showLogArea();
                        end
                    end
                catch Mex %#ok<NASGU>
                    stopped=true;
                end
            end
        end

        function displaySummaryLog(obj,sldvData,fileNames)
            try
                htmlSummry=Sldv.ReportUtils.getHTMLsummary(sldvData,...
                fileNames,...
                get_param(obj.mModelH,'Name'),...
                false);

                obj.mTestComp.progressUI.setLog(htmlSummry);
            catch Mex %#ok<NASGU>
            end
        end

        function removeModelHighlighting(obj,modelH)


            if obj.mShowUI
                handles=get_param(modelH,'AutoVerifyData');
                if isfield(handles,'modelView')&&handles.modelView.isvalid

                    SLStudio.Utils.RemoveHighlighting(modelH);

                    delete(handles.modelView);
                    handles=rmfield(handles,'modelView');
                    set_param(modelH,'AutoVerifyData',handles);
                end
            end
        end

        function removeReportLinkWarn(~,modelH)




            handle=get_param(modelH,'AutoVerifyData');
            if isfield(handle,'msgBoxReportLinkWarn')

                if ishandle(handle.msgBoxReportLinkWarn)
                    delete(handle.msgBoxReportLinkWarn);
                end
                handle=rmfield(handle,'msgBoxReportLinkWarn');
                set_param(modelH,'AutoVerifyData',handle);
            end
        end

        function out=html_spaced_label_val(~,label,value)
            out=sprintf('\n &nbsp; %s:\n &nbsp; %s\n',label,value);
        end

        fileNames=generateReport(obj,sldvData,format,fileNames);

        [sldvData,fileNames,goalIdToObjectiveIdMap]=generateData(obj,settings,fileNames);

        fileNames=generateHarness(obj,sldvData,fileNames);

        function msg=displayMessages(obj)
            msg=[];
            testComp=obj.mTestComp;

            [~,~,msgVect]=sldvshareprivate('avtcgirunsuppost');
            if testComp.hasAnalysisErrs||testComp.hasUnsatisfiableObjs||...
                ~strcmp('Completed normally',testComp.analysisStatus)||...
                (~isempty(msgVect)&&(length(msgVect)~=1||...
                any(~strcmpi(msgVect{1},getString(message('Sldv:SldvRun:NoInformation'))))))

                sldvprivate('mdl_create_unsafe_cast_errors',testComp);
                obj.processDiagnostics();
                msg=sldvshareprivate('avtcgirunsupdialog',...
                testComp.analysisInfo.analyzedModelH,obj.mShowUI);
            end

            return;
        end





        function processDiagnostics(obj)
            testComp=obj.mTestComp;

            [~,~,~,msgIds]=sldvshareprivate('avtcgirunsuppost');
            reqdMsgId='Sldv:DVOTOOLS:TestCaseMaxDepth';
            nObjects=length(msgIds);
            for i=1:nObjects
                if any(strcmp(reqdMsgId,msgIds{i}))&&...
                    strcmp('Completed normally',testComp.analysisStatus)
                    sldvshareprivate('avtcgirunsupcollect',...
                    'removeWithMessage',[],[],[],...
                    reqdMsgId);
                end
            end
        end
        function logger(~,testcomp,showUI,logAll,str)

            if sldvshareprivate('util_is_analyzing_for_fixpt_tool')
                return;
            end

            if showUI
                if~isempty(testcomp)&&isa(testcomp,'SlAvt.TestComponent')


                    try
                        testcomp.progressUI.appendToLog(str);
                    catch Mex %#ok<NASGU>
                    end
                else
                    if logAll
                        str=sldvshareprivate('util_remove_html',str);
                        fprintf(1,str);
                    end
                end
            else
                if logAll
                    str=sldvshareprivate('util_remove_html',str);
                    fprintf(1,'%s',str);
                end
            end
        end

        function recordErroredObjectives(obj)
            testComp=obj.mTestComp;
            entries=testComp.analysisInfo.erroredObjectivesInfo.keys;
            testComp.hasAnalysisErrs=~isempty(entries);
            for idx=1:length(entries)
                errorMsgStructure=testComp.analysisInfo.erroredObjectivesInfo(entries{idx});
                sldvshareprivate('avtcgirunsupcollect','push',...
                errorMsgStructure.objH,...
                errorMsgStructure.src,...
                getString(message('Sldv:SldvRun:ErrorDuringAnalysis',errorMsgStructure.goalTxt)),...
                'Sldv:SldvRun:GoalMessage');
            end
        end

        verifyTestObjectives(obj);
    end


    methods(Access=public)
        function obj=Analyzer(modelH,blockH,blockPathObj,sldvOpts,showUI,initCovData,testComp)
            obj.mModelH=modelH;
            obj.mBlockH=blockH;
            obj.mBlockPathObj=blockPathObj;
            obj.mSldvOpts=sldvOpts;
            obj.mShowUI=showUI;
            obj.mInitCovData=initCovData;
            obj.mTestComp=testComp;

            obj.mAnalysisStatus=Sldv.AnalysisStatus.None;




            period=1;
            obj.mAnalysisTimer=internal.IntervalTimer(period);

            obj.mResultsUpdateAvailable=true;
            obj.mTaskingFF=slfeature('SldvTaskingArchitecture');

        end

        function delete(obj)


            slavteng('feature','BitPreciseAnalysis',0);
            slavteng('feature','FloatPtOvf',0);
            slavteng('feature','SubnormalChk',0);


            if~isempty(obj.mTimeOutListener)
                clear('obj.mTimeOutListener');
                obj.mTimeOutListener=[];
            end


            if~isempty(obj.mAnalysisTimer)
                if obj.mAnalysisTimer.isRunning
                    stop(obj.mAnalysisTimer);
                end
                clear('obj.mAnalysisTimer');
                obj.mAnalysisTimer=[];
            end
            obj.mTaskQueue=[];
            obj.mResultStream=[];

        end

    end
end

