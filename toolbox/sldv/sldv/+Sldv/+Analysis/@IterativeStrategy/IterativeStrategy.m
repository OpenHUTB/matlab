




classdef IterativeStrategy<Sldv.Analysis.Strategy
    properties
        mDvoAnalyzer=[];
        mTestComp=[];
        mEnabledGoals=[];
        mNumIterations=0;
        mGoalsPerIter=0;
        mIterNum=0;
        mTimeout=0;
    end

    methods(Access=public)
        function init(obj)
            obj.recordEnabledGoals();

            obj.mNumIterations=4;
            obj.mGoalsPerIter=floor(length(obj.mEnabledGoals)/obj.mNumIterations);
            obj.mIterNum=1;
            obj.mTimeout=obj.mTestComp.activeSettings.MaxProcessTime;
            obj.mTestComp.setInternalStrategy('CombinedObjectives');
            options=containers.Map('KeyType','char','ValueType','any');
            options('MaxProcessTime')=obj.mTimeout/obj.mNumIterations;
            obj.mDvoAnalyzer.setAnalysisOptions(options);

            return;
        end

        function strategyState=solveNext(obj)
            goalsStartIdx=obj.mGoalsPerIter*(obj.mIterNum-1)+1;
            goalsEndIdx=goalsStartIdx+obj.mGoalsPerIter-1;
            goals=obj.mEnabledGoals(goalsStartIdx:goalsEndIdx);
            obj.mDvoAnalyzer.setAnalysisGoals(goals);


            analysisInput=[];
            analysisInput.goals=goals;

            testCaseIds=obj.mTestComp.getAllTestCaseIds();
            if~isempty(testCaseIds)
                numTests=length(testCaseIds);
                singleTestExtensionSpec.testId=-1;
                singleTestExtensionSpec.extensionSpec=[-1,-1];
                analysisInput.testCaseExtensionSpec=repmat(singleTestExtensionSpec,numTests,1);
                for tcNum=1:numTests
                    tId=testCaseIds(tcNum);
                    tc=obj.mTestComp.getTestCase(tId);
                    analysisInput.testCaseExtensionSpec(tcNum).testId=tId;
                    analysisInput.testCaseExtensionSpec(tcNum).extensionSpec(1)=floor(tc.length/4);
                    analysisInput.testCaseExtensionSpec(tcNum).extensionSpec(2)=floor(tc.length/2);
                end
            end



            status=false;
            try
                [status,msg]=obj.mDvoAnalyzer.runAnalysisAsync(analysisInput);
            catch MEx
                obj.mState=Sldv.Analysis.StrategyState.Failed;
                if~isvalid(obj)

                    MEx=MException('Sldv:AnalysisStrategy:invalidObj',...
                    'SLDV AnalysisStrategy is no longer valid');
                    throw(MEx);
                end
            end

            if~status
                obj.mState=Sldv.Analysis.StrategyState.Failed;
            else
                obj.mState=Sldv.Analysis.StrategyState.AsyncRunning;
            end

            strategyState=obj.mState;

            return;
        end

        function strategyState=finishAsyncSolver(obj)
            obj.mDvoAnalyzer.finishAnalysis();
            obj.mState=Sldv.Analysis.StrategyState.AsyncDone;

            obj.mIterNum=obj.mIterNum+1;

            if(obj.mIterNum>obj.mNumIterations)

                obj.wrap();
                obj.mState=Sldv.Analysis.StrategyState.Done;
            end

            strategyState=obj.mState;

            return;
        end

        function terminate(obj,cause)
            if(Sldv.Analysis.StrategyState.AsyncRunning==obj.mState)
                notifyOnTerminate=false;
                obj.mDvoAnalyzer.terminateAsyncAnalysis(notifyOnTerminate,cause);
            end

            obj.wrap();
            obj.mState=Sldv.Analysis.StrategyState.Terminated;

            return;
        end

        function wrap(obj)

            obj.mTestComp.setInternalStrategy('');

            return;
        end
    end

    methods(Access=public)

        function obj=IterativeStrategy(dvoAnalyzer,testComp)
            obj=obj@Sldv.Analysis.Strategy();

            obj.mDvoAnalyzer=dvoAnalyzer;
            obj.mTestComp=testComp;
        end

        function delete(~)
        end
    end

    methods(Access=private)
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
