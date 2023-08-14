






classdef SimpleStrategy<Sldv.Analysis.Strategy
    properties
        mDvoAnalyzer=[];
    end

    methods(Access=public)
        function init(obj)
        end

        function strategyState=solveNext(obj)

            status=false;
            try
                [status,msg]=obj.mDvoAnalyzer.runAnalysisAsync();
            catch MEx
                obj.mState=Sldv.Analysis.StrategyState.Failed;
                strategyState=obj.mState;
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


            obj.mState=Sldv.Analysis.StrategyState.Done;
            strategyState=obj.mState;

            return;
        end

        function terminate(obj,cause)
            if(Sldv.Analysis.StrategyState.AsyncRunning==obj.mState)
                notifyOnTerminate=false;
                obj.mDvoAnalyzer.terminateAsyncAnalysis(notifyOnTerminate,cause);
            end

            obj.mState=Sldv.Analysis.StrategyState.Terminated;

            return;
        end
    end

    methods(Access=public)

        function obj=SimpleStrategy(dvoAnalyzer,testComp)
            obj=obj@Sldv.Analysis.Strategy();

            obj.mDvoAnalyzer=dvoAnalyzer;
        end

        function delete(~)
        end
    end

end
