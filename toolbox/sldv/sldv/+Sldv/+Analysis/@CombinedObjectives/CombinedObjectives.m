classdef CombinedObjectives<Sldv.Analysis.Strategy



    properties
        mDvoAnalyzer=[];
        mTestComp=[];
        mSldvObjectivesData=[];
        mEnabledGoals=[];
    end

    methods(Access=public)

        function init(obj,dataStruct)
            if nargin==2
                obj.mSldvObjectivesData=dataStruct.sldvData;
            else
                obj.mSldvObjectivesData=[];
            end
        end

        function strategyState=solveNext(obj)
            analysisOptions=obj.getOptionsForCombinedObjectives();
            obj.mDvoAnalyzer.setAnalysisOptions(analysisOptions);
            try
                LoggerId='sldv::task_manager';
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::CombinedObjectives - Starting async analysis');
                analysisInput=[];
                analysisInput.goals=obj.mEnabledGoals;
                [status,msg]=obj.mDvoAnalyzer.runAnalysisAsync(analysisInput);
                sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::CombinedObjectives - Async analysis started');
            catch MEx
                obj.mState=Sldv.Analysis.StrategyState.Failed;
                if~isvalid(obj)
                    MEx=MException('Sldv:AnalysisStrategy:invalidObj',...
                    'SLDV AnalysisStrategy is no longer valid');
                    throw(MEx);
                end
            end

            if~status
                obj.mTestComp.setInternalStrategy('');
                obj.mState=Sldv.Analysis.StrategyState.Failed;
            else
                obj.mState=Sldv.Analysis.StrategyState.AsyncRunning;
            end
            strategyState=obj.mState;

            return;
        end

        function strategyState=finishAsyncSolver(obj)
            obj.mTestComp.setInternalStrategy('');
            LoggerId='sldv::task_manager';
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::CombinedObjectives - Finishing async analysis');
            obj.mDvoAnalyzer.finishAnalysis();
            sldvprivate('SLDV_LOG_DEBUG',LoggerId,'Analysis::CombinedObjectives - Async analysis finished');
            obj.mState=Sldv.Analysis.StrategyState.Done;
            strategyState=obj.mState;
        end


        function setAnalysisGoals(obj,goals)
            assert(nargin==2);
            obj.mEnabledGoals=goals;
            obj.mDvoAnalyzer.setAnalysisGoals(goals);
        end

        function terminate(obj,cause)
            obj.mTestComp.setInternalStrategy('');
            if(Sldv.Analysis.StrategyState.AsyncRunning==obj.mState)
                notifyOnTerminate=false;
                obj.mDvoAnalyzer.terminateAsyncAnalysis(notifyOnTerminate,cause);
            end

            obj.mState=Sldv.Analysis.StrategyState.Terminated;
        end
    end

    methods(Access=public)

        function obj=CombinedObjectives(dvoAnalyzer,testComp)
            obj=obj@Sldv.Analysis.Strategy();
            obj.mDvoAnalyzer=dvoAnalyzer;
            obj.mTestComp=testComp;
        end
    end

    methods(Access=private)

        function options=getOptionsForCombinedObjectives(obj)
            obj.mTestComp.setInternalStrategy('CombinedObjectives');
            options=containers.Map(...
            'KeyType','char',...
            'ValueType','any');

            userOptions=obj.mDvoAnalyzer.getSldvOptions();
            totalTime=userOptions.MaxProcessTime;
            elapsedTime=obj.mTestComp.getElapsedTime();
            options('MaxProcessTime')=totalTime-elapsedTime;


            options('ExtendExistingTests')=userOptions.ExtendExistingTests;
            options('ExistingTestFile')=userOptions.ExistingTestFile;
            options('IgnoreExistTestSatisfied')=userOptions.IgnoreExistTestSatisfied;

        end

    end

end


