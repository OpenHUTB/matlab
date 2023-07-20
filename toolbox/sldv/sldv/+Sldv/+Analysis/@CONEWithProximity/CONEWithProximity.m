




classdef CONEWithProximity<Sldv.Analysis.Strategy
    properties
        mDvoAnalyzer=[];
        mTestComp=[];
        mEnabledGoals=[];
        mStrategySequence={'Concolic','Proximity','CombinedObjectives'};
        mCurrentStrategy='';
        mIterNum=0;
    end
    properties
        mConcolic=[];
        mProximity=[];
        mCombinedObjectives=[];
        mSldvObjectivesData=[];
    end

    properties
        mGoalIdToObjectiveIdMap=[];
        mObjectiveIdToGoalMap=[];
    end

    methods(Access=public)

        function init(obj,sldvData,objIdToGoalMap,goalIdToObjIdMap)
            obj.mSldvObjectivesData=sldvData;
            obj.mObjectiveIdToGoalMap=objIdToGoalMap;
            obj.mGoalIdToObjectiveIdMap=goalIdToObjIdMap;

            dataStruct.sldvData=obj.mSldvObjectivesData;
            dataStruct.goalIdToObjectiveIdMap=obj.mGoalIdToObjectiveIdMap;
            dataStruct.processedTestCases=0;
            obj.mCurrentStrategy='Concolic';
            obj.mConcolic.init(dataStruct);
            obj.mConcolic.setAnalysisGoals(obj.mEnabledGoals);
        end

        function strategyState=solveNext(obj)

            switch obj.mCurrentStrategy
            case 'Concolic'
                strategyState=obj.mConcolic.solveNext();
            case 'Proximity'
                strategyState=obj.mProximity.solveNext();
            case 'CombinedObjectives'
                strategyState=obj.mCombinedObjectives.solveNext();
            end

            obj.mState=strategyState;
            return;
        end

        function strategyState=finishAsyncSolver(obj)
            testComp=obj.mTestComp;

            switch obj.mCurrentStrategy
            case 'Concolic'
                obj.mState=Sldv.Analysis.StrategyState.AsyncDone;
                obj.mConcolic.finishAsyncSolver();
                dUtils=Sldv.Analysis.DataUtils;
                results=obj.mConcolic.getResults();
                obj.mSldvObjectivesData=dUtils.updateSldvObjectivesData(obj.mSldvObjectivesData,results.data);
                goals=obj.getTargetGoals();
                if isempty(goals)
                    obj.mState=Sldv.Analysis.StrategyState.Done;
                elseif(true==obj.mConcolic.isDone())
                    obj.mCurrentStrategy='Proximity';
                    dataStruct.sldvData=obj.mSldvObjectivesData;
                    dataStruct.goalIdToObjectiveIdMap=obj.mGoalIdToObjectiveIdMap;
                    dataStruct.objectiveIdToGoalMap=obj.mObjectiveIdToGoalMap;
                    if isfield(obj.mSldvObjectivesData,'TestCases')
                        dataStruct.processedTestCases=length(obj.mSldvObjectivesData.TestCases);
                    else
                        dataStruct.processedTestCases=0;
                    end
                    obj.mProximity.init(dataStruct);
                    toRunProximity=obj.mProximity.runProximity();
                    if~toRunProximity
                        obj.mCurrentStrategy='CombinedObjectives';
                        dataStruct.sldvData=obj.mSldvObjectivesData;
                        obj.mCombinedObjectives.init(dataStruct);
                        obj.mCombinedObjectives.setAnalysisGoals(goals);
                    end
                end

            case 'Proximity'
                testComp.skipPolyspaceDeadLogic(true);
                obj.mState=Sldv.Analysis.StrategyState.AsyncDone;
                obj.mProximity.finishAsyncSolver();
                if(true==obj.mProximity.isDone())
                    results=obj.mProximity.getResults();
                    obj.mSldvObjectivesData=results;
                    goals=obj.getTargetGoals();
                    if isempty(goals)
                        obj.mState=Sldv.Analysis.StrategyState.Done;
                    else
                        obj.mCurrentStrategy='CombinedObjectives';
                        dataStruct.sldvData=obj.mSldvObjectivesData;
                        obj.mCombinedObjectives.init(dataStruct);
                        obj.mCombinedObjectives.setAnalysisGoals(goals);
                    end
                end
            case 'CombinedObjectives'
                obj.mCombinedObjectives.finishAsyncSolver();
                obj.mState=Sldv.Analysis.StrategyState.Done;
            end
            analysisStatus=obj.mDvoAnalyzer.getCurrentAnalysisStatus();
            if(Sldv.AnalysisStatus.ContradictoryModel==analysisStatus)
                obj.mState=Sldv.Analysis.StrategyState.Done;
                return;
            end
            if obj.isDone()
                testComp.skipPolyspaceDeadLogic(false);
            end
            strategyState=obj.mState;

        end

        function terminate(obj,cause)
            obj.mState=Sldv.Analysis.StrategyState.Terminated;
            if~isempty(obj.mCurrentStrategy)
                switch obj.mCurrentStrategy
                case 'Concolic'
                    obj.mConcolic.terminate(cause);
                case 'Proximity'
                    obj.mProximity.terminate(cause);
                case 'CombinedObjectives'
                    obj.mCombinedObjectives.terminate(cause);
                end
            end
            obj.mTestComp.skipPolyspaceDeadLogic(false);
            return;
        end
    end

    methods(Access=public)

        function obj=CONEWithProximity(dvoAnalyzer,testComp)
            obj=obj@Sldv.Analysis.Strategy();
            obj.mDvoAnalyzer=dvoAnalyzer;
            obj.mTestComp=testComp;
            obj.recordEnabledGoals();

            obj.mConcolic=Sldv.Analysis.Concolic(...
            obj.mDvoAnalyzer,...
            testComp);
            obj.mProximity=Sldv.Analysis.ProximityStrategy(...
            obj.mDvoAnalyzer,...
            testComp);
            obj.mCombinedObjectives=Sldv.Analysis.CombinedObjectives(...
            obj.mDvoAnalyzer,...
            testComp);

        end
    end

    methods(Access=private)


        function setAnalysisGoals(obj,goals)
            obj.mDvoAnalyzer.setAnalysisGoals(goals);
        end

















        function goals=getTargetGoals(obj)
            allGoalIndices=obj.mEnabledGoals;
            goals=[];
            testComp=obj.mTestComp;

            for idx=1:length(allGoalIndices)
                goal=testComp.getGoal(allGoalIndices(idx));
                if strcmp(goal.status,'GOAL_INDETERMINATE')||...
                    strcmp(goal.status,'GOAL_UNDECIDED_STUB')||...
                    strcmp(goal.status,'GOAL_UNDECIDED_WITH_TESTCASE')||...
                    (strcmp(goal.status,'GOAL_SATISFIABLE_NEEDS_SIMULATION')...
                    &&strcmp(goal.getBackendStatus(),'satapprox'))
                    goalIdx=allGoalIndices(idx);
                    goals(end+1)=goalIdx;%#ok<AGROW>
                end
            end

            return;
        end
        function recordEnabledGoals(obj)

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

            return;
        end

    end

end
