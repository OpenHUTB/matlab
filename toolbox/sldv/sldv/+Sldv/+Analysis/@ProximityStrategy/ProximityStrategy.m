classdef ProximityStrategy<Sldv.Analysis.Strategy





    properties
        mDvoAnalyzer=[];
        mTestComp=[];
        mSldvObjectivesData=[];
        mGoalIdToObjectiveIdMap=[];
        mObjectiveIdToGoalMap=[];
    end
    properties
        mConcolic=[];
        mProver=[];
        mProximityMgr=[];
        mStrategySequence={'Concolic','ProverTCG'};
        mCurrentStrategy='';
        mIterNum=0;
        processedTestCases=0;
        mTestPrefixes=[];
        mOutputDir='';
        mAdditionalTestPrefixes=[];
    end
    properties
        PROXIMITY_TIME_ALLOCATED=0.3;
        timePerProverCall=[];
        allowedProximityTime=[];
        strategyStartTime=[];
    end
    properties
        DEBUG_FLAG=false;
        debugStruct=[];
        mLoggerId='sldv::task_manager';
    end

    methods(Access=public)

        function status=init(obj,dataStruct)
            testComp=obj.mTestComp;

            if nargin==2
                obj.mSldvObjectivesData=dataStruct.sldvData;
                obj.mObjectiveIdToGoalMap=dataStruct.objectiveIdToGoalMap;
                obj.mGoalIdToObjectiveIdMap=dataStruct.goalIdToObjectiveIdMap;
                obj.processedTestCases=dataStruct.processedTestCases;

            else

                [obj.mSldvObjectivesData,...
                obj.mObjectiveIdToGoalMap,...
                obj.mGoalIdToObjectiveIdMap]=Sldv.DataUtils.save_data(...
                testComp.analysisInfo.analyzedModelH,...
                testComp);
            end



            elapsedTime=testComp.getElapsedTime();
            obj.strategyStartTime=elapsedTime;
            obj.mOutputDir=sldvprivate('mdl_get_output_dir',testComp);
            status=true;
        end



        function status=runProximity(obj)
            status=true;
            if obj.DEBUG_FLAG
                disp('****************** Proximity Started****************');
            end
            try
                obj.initProximityData();
            catch MEx %#ok<NASGU>
                return;
            end

            obj.logData('After Concolic');
            status=obj.mProximityMgr.hasNextSetObjectives();
            if status
                obj.updateTimeForProverCalls();
                obj.setConfigForProver();
            end
            obj.saveProximityData();
        end

        function strategyState=solveNext(obj)

            switch obj.mCurrentStrategy
            case 'Concolic'
                strategyState=obj.mConcolic.solveNext();
            case 'ProverTCG'
                strategyState=obj.mProver.solveNext(obj.timePerProverCall);
            end
            obj.mState=strategyState;
            return;
        end

        function strategyState=finishAsyncSolver(obj)
            switch obj.mCurrentStrategy
            case 'Concolic'
                obj.mState=Sldv.Analysis.StrategyState.AsyncDone;
                obj.mConcolic.finishAsyncSolver();
                results=obj.mConcolic.getResults();
                obj.logData('Decided Objectives',results.objIndices);
                if~isempty(results.objIndices)
                    obj.updateResults(results);
                end
                if obj.toContinueAnalysis()
                    obj.setConfigForProver();
                else
                    obj.mState=Sldv.Analysis.StrategyState.Done;
                end
            case 'ProverTCG'
                obj.mState=Sldv.Analysis.StrategyState.AsyncDone;
                obj.mProver.finishAsyncSolver();
                results=obj.mProver.getResults();
                obj.logData('Decided Objectives',results.objIndices);






                if~isempty(results.objIndices)
                    obj.updateResults(results);
                    if obj.toContinueAnalysis()

                        if obj.toRunConcolic(results.objIndices)
                            obj.mCurrentStrategy='Concolic';
                            dataStruct=obj.getDataWithoutPrefixes();
                            obj.mConcolic.init(dataStruct);

                            goals=obj.getUndecGoals();
                            obj.mConcolic.setAnalysisGoals(goals);
                        else
                            obj.setConfigForProver();
                        end
                    else
                        obj.mState=Sldv.Analysis.StrategyState.Done;
                    end
                else
                    obj.mState=Sldv.Analysis.StrategyState.Done;
                end
            end


            analysisStatus=obj.mDvoAnalyzer.getCurrentAnalysisStatus();
            if(Sldv.AnalysisStatus.ContradictoryModel==analysisStatus)
                obj.mState=Sldv.Analysis.StrategyState.Done;
            end
            obj.mIterNum=obj.mIterNum+1;
            if obj.mState==Sldv.Analysis.StrategyState.Done
                obj.logData('Before Combined Objectives');
                if obj.DEBUG_FLAG
                    disp('**************Proximity Ended**********************');
                end
                obj.saveArtifacts();
            end
            strategyState=obj.mState;
            return;
        end

        function incrementalResults=getResults(obj)
            incrementalResults=obj.mSldvObjectivesData;
        end

        function setAnalysisGoals(obj,goals)
            obj.mDvoAnalyzer.setAnalysisGoals(goals);
        end

        function terminate(obj,cause)
            if~isempty(obj.mCurrentStrategy)
                switch obj.mCurrentStrategy
                case 'Concolic'
                    obj.mConcolic.terminate(cause);
                case 'ProverTCG'
                    obj.mProver.terminate(cause);
                end
            end
            obj.mState=Sldv.Analysis.StrategyState.Terminated;
            return;
        end
    end

    methods(Access=public)

        function obj=ProximityStrategy(dvoAnalyzer,testComp)
            obj=obj@Sldv.Analysis.Strategy();

            obj.mDvoAnalyzer=dvoAnalyzer;
            obj.mTestComp=testComp;

            obj.mConcolic=Sldv.Analysis.Concolic(...
            obj.mDvoAnalyzer,...
            testComp);

            obj.mProver=Sldv.Analysis.ProverTCG(...
            obj.mDvoAnalyzer,...
            testComp);
            obj.DEBUG_FLAG=(slavteng('feature','DebugLevel')==-100);
        end


    end


    methods(Access=private)
        function status=toRunConcolic(obj,newObjIndices)
            status=~isempty(newObjIndices);
            if~status
                return;
            end

            objectives=obj.mSldvObjectivesData.Objectives(newObjIndices);
            objDescriptions={objectives.descr};
            stateExitedString=getString(message(...
            'Slvnv:simcoverage:make_formatters:MSG_SF_INACTIVE_BEFORE_EXIT_D'));
            objFlags=cellfun(@(str)...
            contains(str,stateExitedString),...
            objDescriptions);
            status=~all(objFlags);

        end

        function goals=getGoalsFromObjIndices(obj,objIndices)

            obj.logData('Target Objectives',objIndices);
            goals=[];
            for idx=1:length(objIndices)
                objIdx=objIndices(idx);
                goal=obj.mObjectiveIdToGoalMap(objIdx);
                goalIdx=goal.getGoalMapId();
                goals(end+1)=goalIdx;%#ok<AGROW>
            end
        end

        function setConfigForConcolic(obj)
            obj.mCurrentStrategy='Concolic';
            dataStruct=obj.getDataWithoutPrefixes();
            obj.mConcolic.init(dataStruct);

            goals=obj.getUndecGoals();
            obj.mConcolic.setAnalysisGoals(goals);
        end

        function setConfigForProver(obj)
            obj.mCurrentStrategy='ProverTCG';
            targetData=obj.mProximityMgr.getTargetData();






            dataStruct=obj.getDataWithPrefixes(targetData);
            obj.mProver.init(dataStruct);
            goals=obj.getGoalsFromObjIndices(targetData.objIndices);
            obj.mProver.setAnalysisGoals(goals);
        end

        function updateProximityData(obj,objIndices)
            obj.mProximityMgr.updateProximityData(objIndices);
        end
        function initProximityData(obj)
            obj.mProximityMgr=Sldv.Analysis.ProximityData.ProximityDataCalculator();
            obj.mProximityMgr.initialize(obj.mSldvObjectivesData);
            targetObjIndices=obj.getUndecObjIndices();
            obj.mProximityMgr.populateData(targetObjIndices);
        end

        function objIndices=getUndecObjIndices(obj)

            undecObjIndices=Sldv.Analysis.DataUtils.getUndecObjectives(obj.mSldvObjectivesData.Objectives);
            objIndices=[];
            for idx=1:length(undecObjIndices)
                objIdx=undecObjIndices(idx);
                goal=obj.mObjectiveIdToGoalMap(objIdx);


                if strcmp(goal.status,'GOAL_INDETERMINATE')
                    objIndices(end+1)=objIdx;%#ok<AGROW>
                end
            end

        end
        function goals=getUndecGoals(obj)

            objIndices=obj.getUndecObjIndices();
            obj.logData('Target Objectives',objIndices);
            goals=obj.getGoalsFromObjIndices(objIndices);
        end

        function updateResults(obj,results)


            utils=Sldv.Analysis.DataUtils;
            obj.mSldvObjectivesData=utils.updateSldvObjectivesData(...
            obj.mSldvObjectivesData,results.data);
            obj.updateProximityData(results.objIndices);
            obj.processedTestCases=obj.processedTestCases+...
            length(results.data.TestCases);

        end

        function dataStruct=getDataWithPrefixes(obj,targetData)
            utils=Sldv.Analysis.DataUtils;
            testPrefixes=utils.getTCPrefixes(obj.mSldvObjectivesData,...
            targetData.proximityObjIndices);
            predPrefixes=utils.getTCPrefixes(obj.mSldvObjectivesData,...
            targetData.closestObjIndices,true);
            existingTestCases=obj.mSldvObjectivesData.TestCases;
            dataCopy=obj.mSldvObjectivesData;
            dataCopy.TestCases=[existingTestCases,testPrefixes,predPrefixes];
            dataStruct.sldvData=dataCopy;
            dataStruct.goalIdToObjectiveIdMap=obj.mGoalIdToObjectiveIdMap;
            dataStruct.processedTestCases=length(obj.mSldvObjectivesData.TestCases);
        end

        function dataStruct=getDataWithoutPrefixes(obj)
            dataStruct.sldvData=obj.mSldvObjectivesData;
            dataStruct.goalIdToObjectiveIdMap=obj.mGoalIdToObjectiveIdMap;
            dataStruct.processedTestCases=length(obj.mSldvObjectivesData.TestCases);
        end

        function status=toContinueAnalysis(obj)
            elapsedTime=obj.mTestComp.getElapsedTime();
            proximityRuntime=elapsedTime-obj.strategyStartTime;
            if proximityRuntime>obj.allowedProximityTime
                status=false;
                return;
            end
            status=obj.mProximityMgr.hasNextSetObjectives();
        end
        function updateTimeForProverCalls(obj)
            userOptions=obj.mDvoAnalyzer.getSldvOptions();
            totalTime=userOptions.MaxProcessTime;
            elapsedTime=obj.mTestComp.getElapsedTime();

            remainingTime=totalTime-elapsedTime;
            timeForProximity=(obj.PROXIMITY_TIME_ALLOCATED)*remainingTime;


            obj.timePerProverCall=ceil(0.05*remainingTime);
            obj.allowedProximityTime=timeForProximity;
        end

    end


    methods(Access=private)
        function logData(obj,phase,data)
            if obj.DEBUG_FLAG





                if nargin==2
                    undecObjIndices=Sldv.Analysis.DataUtils.getUndecObjectives(...
                    obj.mSldvObjectivesData.Objectives);
                    data=undecObjIndices;
                end

                iteration=obj.mIterNum;
                strategy=obj.mCurrentStrategy;
                elapsedTime=obj.mTestComp.getElapsedTime();
                sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,...
                ['Iteration:',num2str(iteration),':Strategy:',strategy]);
                disp(['Iteration:',num2str(iteration),':Strategy:',strategy]);
                sldvprivate('SLDV_LOG_DEBUG',obj.mLoggerId,...
                ['Phase:',phase,':Data:',num2str(data),':Time: ',num2str(elapsedTime)]);
                disp(['Phase:',phase,':Data:',num2str(data),':Time: ',num2str(elapsedTime)]);
                newData.iteration=iteration;
                newData.strategy=strategy;
                newData.phase=phase;
                newData.data=data;
                newData.time=elapsedTime;
                if isempty(obj.debugStruct)
                    obj.debugStruct=newData;
                else
                    obj.debugStruct(end+1)=newData;
                end
            end

            return;
        end

        function saveArtifacts(obj)
            if obj.DEBUG_FLAG
                srcDir=obj.mOutputDir;
                outputDir=[srcDir,filesep,'debug_Data'];
                debugData=obj.debugStruct;
                save([outputDir,filesep,'DebugData.mat'],'debugData');
            end

            return;
        end

        function saveProximityData(obj)
            if obj.DEBUG_FLAG
                staticData.timeForProximity=obj.allowedProximityTime;
                staticData.timePerProverCall=obj.timePerProverCall;
                proxData=obj.mProximityMgr.getProximityData();
                staticData.proximityTable=proxData;
                staticData.entriesInTable=length(proxData);
                srcDir=obj.mOutputDir;
                outputDir=[srcDir,filesep,'debug_Data'];
                if~exist(outputDir,'dir')
                    mkdir(outputDir);
                end
                save([outputDir,filesep,'ProxData.mat'],'staticData');
            end

            return;
        end

    end

end
