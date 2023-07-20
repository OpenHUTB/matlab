




classdef ValidatorTask<Sldv.Tasking.Task

    properties(Access=private)
        mTestComp=[];
        mValidator=[];
        mSldvAnalyzer Sldv.Analyzer


        mRemainingTestCases;


        isNoOp=false;



        numWorkers=1;
        useParallelPool=false;
        origPoolTimeout=[];


        mCurrentTestCases=[];

        mFutures=[];
        mFuturesCount=0;

        mGoals;
        mTcGoalIds;

        mProfileLogger;
    end


    methods(Access=public)
        function obj=ValidatorTask(aTaskMgrH,aReady,aTestComp,aSldvAnalyzer)
            obj=obj@Sldv.Tasking.Task(aTaskMgrH,aReady);



            obj.triggerOn(Sldv.Tasking.SldvEvents.AnalysisInit);


            obj.connect(Sldv.Tasking.SldvChannels.ProcessedTestCases,...
            Sldv.Tasking.ChannelConnectMode.Read);


            obj.connect(Sldv.Tasking.SldvChannels.ProcessedGoals,...
            Sldv.Tasking.ChannelConnectMode.Read);


            obj.connect(Sldv.Tasking.SldvChannels.ValidatedGoals,...
            Sldv.Tasking.ChannelConnectMode.Write);
            obj.connect(Sldv.Tasking.SldvChannels.ValidatedTestCases,...
            Sldv.Tasking.ChannelConnectMode.Write);

            obj.mTestComp=aTestComp;

            obj.mSldvAnalyzer=aSldvAnalyzer;

        end

        function delete(~)
        end

    end


    methods(Access=protected)
        function status=doTask(obj,aEvent)

            assert(~isempty(obj.mTestComp));

            LoggerId='sldv::task_manager';
            status=true;
            switch aEvent
            case Sldv.Tasking.SldvEvents.AnalysisInit
                obj.init();

            case Sldv.Tasking.SldvChannels.ProcessedGoals
                status=obj.evaluateProcessedGoals(aEvent);

            case Sldv.Tasking.SldvChannels.ProcessedTestCases
                if~isempty(obj.mFutures)
                    status=obj.evaluateCompletedFutures(aEvent);
                else
                    status=obj.evaluateProcessedTestCases(aEvent);
                end

                if obj.hasPendingTasks()
                    obj.yield();
                    logStr=sprintf('ValidatorTask[%s] - Yielded',aEvent);
                    sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
                end

            otherwise
                assert(false,'ValidatorTask received an invalid event');
            end

            return;
        end

        function doCleanup(obj,cause)%#ok<INUSD>



            obj.flush();


            obj.disConnect(Sldv.Tasking.SldvChannels.ValidatedGoals);
            obj.disConnect(Sldv.Tasking.SldvChannels.ValidatedTestCases);

            if(~isempty(obj.mValidator))
                assert(isvalid(obj.mValidator));
                if~obj.isNoOp


                    obj.mValidator.restore();
                end

                delete(obj.mValidator);
                obj.mValidator=[];

                if obj.useParallelPool
                    pool=gcp('nocreate');






                    if~isempty(pool)
                        if~isempty(obj.origPoolTimeout)
                            pool.IdleTimeout=obj.origPoolTimeout;
                        end
                    else
                        obj.isNoOp=true;



                        msgID='Sldv:SldvRun:NoParallelPool';
                        msg=getString(message(msgID));

                        sldvshareprivate('avtcgirunsupcollect','push',...
                        obj.mTestComp.analysisInfo.extractedModelH,'sldv',msg,msgID);
                    end
                end
            end

            obj.mProfileLogger.logTerminateThread();

            return;
        end

        function flush(obj)

            obj.evaluateProcessedGoals('FLUSH');



            cacheNoOp=obj.isNoOp;
            obj.isNoOp=true;
            while(1)
                if~isempty(obj.mFutures)
                    obj.evaluateCompletedFutures('FLUSH');
                else
                    obj.evaluateProcessedTestCases('FLUSH');
                end

                if obj.isValidationComplete()
                    break;
                end
            end
            obj.isNoOp=cacheNoOp;

            return;
        end
    end

    methods(Access=private)

        function init(obj)
            obj.mProfileLogger=obj.mTestComp.getValidationProfileLogger;

            try
                [sldvData,objectiveIdToGoalMap,goalIdToObjectiveIdMap]=...
                obj.mSldvAnalyzer.getStaticSldvData();
                obj.mValidator=...
                sldvprivate('getValidator',sldvData,...
                obj.mTestComp.analysisInfo.extractedModelH,...
                objectiveIdToGoalMap,obj.mTestComp,goalIdToObjectiveIdMap);
            catch



                obj.mValidator=[];
            end



            obj.useParallelPool=false;
            if slavteng('feature','UseParallelSimulations')
                sldvOpts=obj.mTestComp.activeSettings;
                if(strcmp(sldvOpts.UseParallel,'on'))
                    obj.useParallelPool=true;
                end
            end


            Sldv.utils.getBusObjectFromName(-1);

            try


                if~isempty(obj.mValidator)
                    obj.mProfileLogger.openPhase('Initialize Validator');
                    obj.useParallelPool=obj.mValidator.initialize(obj.useParallelPool);
                    obj.mProfileLogger.closePhase('Initialize Validator');
                else


                    obj.done();
                    return;
                end
            catch Mex %#ok<NASGU>
                obj.mProfileLogger.closePhase('Initialize Validator');


                obj.isNoOp=true;
                return;
            end




            if obj.useParallelPool
                obj.mProfileLogger.openPhase('Initialize parpool');

                pool=gcp('nocreate');
                if~isempty(pool)
                    obj.numWorkers=pool.NumWorkers;


                    maxProcessTime=ceil(obj.mTestComp.activeSettings.MaxProcessTime/60);
                    if maxProcessTime>pool.IdleTimeout
                        obj.origPoolTimeout=pool.IdleTimeout;
                        pool.IdleTimeout=maxProcessTime+5;
                    end
                else




                    obj.useParallelPool=false;
                end

                obj.mProfileLogger.closePhase('Initialize parpool');
            end

            return;
        end

        function status=evaluateProcessedGoals(obj,aEvent)
            status=true;








            if obj.isValidationComplete()
                obj.finalizeValidation();
                obj.done();
                return;
            end


            [status,goalIds,~]=obj.read(Sldv.Tasking.SldvChannels.ProcessedGoals);
            assert(status,'Unable to read from Processed Channel');


            testCaseIds=[];
            obj.logGoalsNTestCases(aEvent,goalIds,testCaseIds);
            testComp=obj.mTestComp;


            validated_goals=[];
            for ind=1:numel(goalIds)
                goal_id=goalIds(ind);
                goal=testComp.getGoal(goal_id);
                if~obj.isPartofTestCase(goal)
                    validated_goals(end+1)=goal_id;%#ok<AGROW>
                end
            end

            if~isempty(validated_goals)
                msgIdentifier='evaluateProcessedGoals::validated_goals';
                obj.debugMSGs(msgIdentifier,validated_goals,[]);
                obj.write(Sldv.Tasking.SldvChannels.ValidatedGoals,validated_goals);


                force=false;
                numGoals=numel(validated_goals);
                for ind=1:numGoals
                    aGoalId=validated_goals(ind);
                    aStatus=testComp.getGoal(aGoalId).status;
                    aTcIdx=0;
                    testComp.updateValidatedGoals(aGoalId,string(aStatus),force,aTcIdx);
                end


                msgIdentifier='ValidatedGoals';
                validatedTestCaseId=[];
                obj.logGoalsNTestCases(msgIdentifier,validated_goals,validatedTestCaseId);
            end

            return;
        end

        function status=evaluateProcessedTestCases(obj,aEvent)
            status=true;





            if obj.isValidationComplete()
                obj.finalizeValidation();
                obj.done();
                return;
            end


            [status,testCaseIds]=obj.read(Sldv.Tasking.SldvChannels.ProcessedTestCases);


            LoggerId='sldv::task_manager';

            if isempty(testCaseIds)
                logStr=sprintf('ValidatorTask - Empty testcases received on [%s] channel',aEvent);
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);



                if isempty(obj.mRemainingTestCases)
                    return;
                end
            end


            goalIds=[];
            obj.logGoalsNTestCases(aEvent,goalIds,testCaseIds);
            testComp=obj.mTestComp;


            for tcNum=1:length(testCaseIds)
                tc=testComp.getTestCase(testCaseIds(tcNum));
                if isempty(obj.mRemainingTestCases)
                    obj.mRemainingTestCases=tc;
                else
                    obj.mRemainingTestCases(end+1)=tc;
                end
            end

            if~isempty(obj.mRemainingTestCases)


                obj.evaluateRemainingTestCases(aEvent);
            end

            return;
        end

        function evaluateRemainingTestCases(obj,aEvent)
            futureData=[];
            if obj.useParallelPool
                if numel(obj.mRemainingTestCases)>obj.numWorkers
                    testCases=obj.mRemainingTestCases(1:obj.numWorkers);
                else
                    testCases=obj.mRemainingTestCases;
                end
            else
                testCases=obj.mRemainingTestCases(1);
            end
            obj.mRemainingTestCases(1:length(testCases))=[];







            goals=cell(1,numel(testCases));
            tcGoalIds=struct('TcIdx',{},'GIdx',{});
            for currTc=1:numel(testCases)


                goals{currTc}=testCases(currTc).goals;
                tcGoalIds(currTc).TcIdx=testCases(currTc).getId();
                for currGoal=1:numel(goals{currTc})
                    tcGoalIds(currTc).GIdx=[tcGoalIds(currTc).GIdx,goals{currTc}(currGoal).getGoalMapId()];
                end
            end
            obj.mGoals=goals;
            obj.mTcGoalIds=tcGoalIds;
            try
                obj.mProfileLogger.openPhase('ValidateIncremental');
                if obj.isNoOp
                    validatedTC=testCases;
                else
                    [validatedTC,futureData,noopValidatedTcIdx]=obj.mValidator.validateIncremental(testCases);
                end
                obj.mProfileLogger.closePhase('ValidateIncremental');
            catch Mex %#ok<NASGU>
                obj.mProfileLogger.closePhase('ValidateIncremental');



                validatedTC=testCases;
            end

            if~isempty(futureData)




                obj.mCurrentTestCases=testCases;
                obj.mFutures=futureData;
                obj.mFuturesCount=numel(obj.mFutures);

                if~isempty(noopValidatedTcIdx)










                    switch obj.mTestComp.activeSettings.Mode
                    case 'PropertyProving'
                        obj.evaluateValidatedTestCases(obj.mCurrentTestCases,obj.mGoals,noopValidatedTcIdx);
                    case{'DesignErrorDetection','TestGeneration'}
                        tcIdx=noopValidatedTcIdx;
                        obj.evaluateValidatedTestCases(validatedTC,obj.mGoals(tcIdx));
                    end
                end


                LoggerId='sldv::task_manager';
                logStr=sprintf('ValidatorTask - Running [%s] simulation(s) on [%s] channel',num2str(obj.mFuturesCount),aEvent);
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            else
                obj.evaluateValidatedTestCases(validatedTC,obj.mGoals);
            end
        end

        function status=evaluateCompletedFutures(obj,aEvent)
            status=true;


            completedFutureIdx=find(strcmp('finished',{obj.mFutures.State}));
            completedFutures=obj.mFutures(completedFutureIdx);
            obj.mFutures(completedFutureIdx)=[];

            LoggerId='sldv::task_manager';
            if isempty(completedFutures)
                logStr=sprintf('ValidatorTask - None of the current simulations have finished on [%s] channel',aEvent);
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
                return;
            else
                completedFuturesCount=obj.mFuturesCount-numel(obj.mFutures);
                logStr=sprintf('ValidatorTask - Completed [%s] of [%s] simulation runs on [%s] channel',...
                num2str(completedFuturesCount),num2str(obj.mFuturesCount),aEvent);
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            end







            switch obj.mTestComp.activeSettings.Mode
            case 'PropertyProving'
                [~,validatedIdx]=obj.mValidator.verifyIncremental(completedFutures,obj.mCurrentTestCases);
                obj.evaluateValidatedTestCases(obj.mCurrentTestCases,obj.mGoals,validatedIdx);
            case{'DesignErrorDetection','TestGeneration'}
                tempIdx=values(obj.mValidator.FutureIdMapForTestcases,{completedFutures.ID});
                completedFuturesToGoalIdx=[tempIdx{:}];
                validatedTC=obj.mValidator.verifyIncremental(completedFutures,obj.mCurrentTestCases);
                obj.evaluateValidatedTestCases(validatedTC(completedFuturesToGoalIdx),obj.mGoals(completedFuturesToGoalIdx));
            end






            if obj.isValidationComplete()
                obj.finalizeValidation();
                obj.done();
                return;
            end
        end

        function evaluateValidatedTestCases(obj,validatedTC,goals,validatedIdx)
            if nargin<4
                validatedIdx=[];
            end
            if isempty(validatedIdx)
                for TCIdx=1:length(validatedTC)
                    validatedTestCaseId=validatedTC(TCIdx).getId();
                    validatedGoalIds=[];
                    for goalNum=1:length(goals{TCIdx})
                        goal=goals{TCIdx}(goalNum);
                        goalId=goal.getGoalMapId();
                        if obj.isNoOp
                            obj.updateNoOpStatus(goalId,validatedTestCaseId)
                        end
                        validatedGoalIds=[validatedGoalIds,goalId];%#ok<AGROW>
                    end


                    validatedGoalIds=obj.filterInternalGoals(validatedGoalIds);


                    msgIdentifier='ValidatedGoals';
                    obj.logGoalsNTestCases(msgIdentifier,validatedGoalIds,validatedTestCaseId);


                    msgIdentifier='evaluateProcessedTestCases::validatedGoalIds';
                    obj.debugMSGs(msgIdentifier,validatedGoalIds,[]);
                    obj.write(Sldv.Tasking.SldvChannels.ValidatedGoals,validatedGoalIds);

                    msgIdentifier='evaluateProcessedTestCases::validatedTestCaseId';
                    obj.debugMSGs(msgIdentifier,[],validatedTestCaseId);
                    obj.write(Sldv.Tasking.SldvChannels.ValidatedTestCases,validatedTestCaseId);
                end
            else
                for eachIdx=1:numel(validatedIdx)
                    currTcObjIdx=validatedIdx{eachIdx};
                    validatedTestCaseId=currTcObjIdx(1);
                    validatedObjectiveId=currTcObjIdx(2);

                    goal=obj.mValidator.objectiveToGoalMap(validatedObjectiveId);
                    goalId=goal.getGoalMapId();



                    localTcId=find([obj.mTcGoalIds.TcIdx]==validatedTestCaseId);
                    localGoalId=find([obj.mTcGoalIds(localTcId).GIdx]==goalId);
                    assert(localGoalId>0);
                    obj.mGoals{localTcId}(localGoalId)=[];

                    if obj.isNoOp
                        obj.updateNoOpStatus(goalId,validatedTestCaseId)
                    end


                    validatedGoalIds=obj.filterInternalGoals(goalId);


                    msgIdentifier='ValidatedGoals';








                    if~isempty(obj.mGoals{localTcId})
                        validatedTestCaseId=[];
                    end
                    obj.logGoalsNTestCases(msgIdentifier,validatedGoalIds,validatedTestCaseId);


                    msgIdentifier='evaluateProcessedTestCases::validatedGoalIds';
                    obj.debugMSGs(msgIdentifier,validatedGoalIds,[]);
                    obj.write(Sldv.Tasking.SldvChannels.ValidatedGoals,validatedGoalIds);



                    if isempty(obj.mGoals{localTcId})
                        msgIdentifier='evaluateProcessedTestCases::validatedTestCaseId';
                        obj.debugMSGs(msgIdentifier,[],validatedTestCaseId);
                        obj.write(Sldv.Tasking.SldvChannels.ValidatedTestCases,validatedTestCaseId);
                    end
                end
                if isempty(obj.mFutures)





                    hasUnvalidatedGoals=find(~cellfun(@isempty,obj.mGoals));
                    if~isempty(hasUnvalidatedGoals)
                        obj.evaluateValidatedTestCases(validatedTC(hasUnvalidatedGoals),obj.mGoals(hasUnvalidatedGoals));
                    end
                end
            end
        end

        function updateNoOpStatus(obj,goalId,validatedTestCaseId)
            testComp=obj.mTestComp;
            goalResult=testComp.getGoalResult(goalId,validatedTestCaseId);
            validatedStatus=goalResult.status;



            if strcmp('GOAL_UNDECIDED_STUB_NEEDS_SIMULATION',validatedStatus)
                validatedStatus='GOAL_UNDECIDED_STUB';
            end
            force=false;
            testComp.updateValidatedGoals(goalId,string(validatedStatus),force,validatedTestCaseId);
        end

        function status=isPartofTestCase(obj,goal)%#ok<INUSL>
            goal_status=goal.status;
























            testCaseGoalStatus={'GOAL_SATISFIABLE','GOAL_FALSIFIABLE','GOAL_SATISFIED_BY_EXISTING_TESTCASE',...
            'GOAL_SATISFIABLE_NEEDS_SIMULATION','GOAL_FALSIFIABLE_NEEDS_SIMULATION',...
            'GOAL_UNDECIDED_STUB_NEEDS_SIMULATION'};

            status=any(contains(testCaseGoalStatus,string(goal_status)));
            if(status)
                LoggerId='sldv::task_manager';
                logStr=sprintf('ValidatorTask::isPartOfTestCase::GoalID::%d',goal.getGoalMapId);
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            end
            return;
        end

        function finalizeValidation(obj)




            if~isempty(obj.mValidator)
                noTestcaseGoals=obj.mValidator.updateNoTestCaseStatus();
                msgIdentifier='evaluateProcessedTestCases::obj.filterInternalGoals(noTestcaseGoals)';
                obj.debugMSGs(msgIdentifier,obj.filterInternalGoals(noTestcaseGoals),[]);
                obj.write(Sldv.Tasking.SldvChannels.ValidatedGoals,obj.filterInternalGoals(noTestcaseGoals));
            end
        end

        function status=isValidationComplete(obj)
            status=false;

            check1=obj.isEof(Sldv.Tasking.SldvChannels.ProcessedTestCases);
            check2=obj.isEof(Sldv.Tasking.SldvChannels.ProcessedGoals);
            check3=isempty(obj.mRemainingTestCases);
            check4=isempty(obj.mFutures);

            if check1&&check2&&check3&&check4
                status=true;
                logStr=sprintf('ValidatorTask - Received EOF on ProcessedTestCases & ProcessedGoals channels');
                LoggerId='sldv::task_manager';
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
            end

            return;
        end

        function status=hasPendingTasks(obj)
            status=true;

            check1=isempty(obj.mRemainingTestCases);
            check2=isempty(obj.mFutures);

            if check1&&check2
                status=false;
                logStr=sprintf('ValidatorTask - No pending tasks');
                LoggerId='sldv::task_manager';
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
            end

            return;
        end

        function filteredGoals=filterInternalGoals(obj,aGoalIds)
            filteredGoals=[];
            testComp=obj.mTestComp;

            for idx=1:numel(aGoalIds)
                goal=testComp.getGoal(aGoalIds(idx));
                if~goal.isInternal()
                    filteredGoals(end+1)=aGoalIds(idx);%#ok<AGROW>
                end
            end

            return;
        end

        function logGoalsNTestCases(obj,msgIdentifier,goalIds,testCaseIds)
            LoggerId='sldv::task_manager';
            logStr=sprintf('ValidatorTask::%s::Start Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            testComp=obj.mTestComp;


            for ind=1:numel(goalIds)
                logStr=sprintf('ValidatorTask::%s::Goal::Id::%d::Status::%s',msgIdentifier,...
                goalIds(ind),testComp.getGoal(goalIds(ind)).status);
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            end


            for ind=1:numel(testCaseIds)
                logStr=sprintf('ValidatorTask::%s::Testcase::Id::%d',msgIdentifier,testCaseIds(ind));
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            end

            logStr=sprintf('ValidatorTask::%s::End Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);

            return;
        end

        function debugMSGs(obj,msgIdentifier,goalIds,testCaseIds)
            LoggerId='sldv::task_manager';
            logStr=sprintf('ValidatorTask::%s::Start Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
            testComp=obj.mTestComp;


            for ind=1:numel(goalIds)
                logStr=sprintf('ValidatorTask::%s::Goal::Id::%d::Status::%s',msgIdentifier,goalIds(ind),...
                testComp.getGoal(goalIds(ind)).status);
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
            end


            for ind=1:numel(testCaseIds)
                logStr=sprintf('ValidatorTask::%s::Testcase::Id::%d',msgIdentifier,testCaseIds(ind));
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);
            end

            logStr=sprintf('ValidatorTask::%s::End Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,logStr);

            return;
        end

    end

end


