




classdef(Abstract)Strategy<handle



    properties(Access=protected)
        mState Sldv.Analysis.StrategyState;
    end

    methods(Access=public)
        function init(obj)
        end







        function strategyStatus=solveNext(obj)
        end



        function strategyStatus=finishAsyncSolver(obj)
        end



        function terminate(obj,cause)
        end


        function strategyStatus=status(obj)
            strategyStatus=obj.mState;

            return;
        end

        function done=isDone(obj)
            done=(Sldv.Analysis.StrategyState.Done==obj.mState);

            return;
        end
    end


    methods(Access=public)

        function obj=Strategy()
            obj.mState=Sldv.Analysis.StrategyState.None;
        end

        function delete(~)
        end
    end
end
