




classdef AnalysisTask<Sldv.Tasking.Task

    properties(Access=private)
        mAnalysisStrategy=[];
        mStrategyState=Sldv.Analysis.StrategyState.None;
    end


    methods(Access=public)
        function obj=AnalysisTask(aTaskMgrH,aReady,aAnalysisStrategy)
            obj=obj@Sldv.Tasking.Task(aTaskMgrH,aReady);

            obj.triggerOn(Sldv.Tasking.SldvEvents.AnalysisInit);
            obj.triggerOn(Sldv.Tasking.SldvEvents.AsyncAnalysisLaunched);
            obj.triggerOn(Sldv.Tasking.SldvEvents.AsyncAnalysisUpdate);
            obj.triggerOn(Sldv.Tasking.SldvEvents.AsyncAnalysisDone);
            obj.triggerOn(Sldv.Tasking.SldvEvents.SyncAnalysisDone);

            obj.mAnalysisStrategy=aAnalysisStrategy;
        end

        function delete(~)
        end
    end


    methods(Access=protected)
        function status=doTask(obj,aEvent)

            assert(~isempty(obj.mAnalysisStrategy)&&isvalid(obj.mAnalysisStrategy));

            status=true;
            switch aEvent
            case Sldv.Tasking.SldvEvents.AnalysisInit
                try
                    obj.mAnalysisStrategy.init();
                catch MEx
                    obj.done();
                    return;
                end

                obj.solveNext();

            case Sldv.Tasking.SldvEvents.AsyncAnalysisLaunched

            case Sldv.Tasking.SldvEvents.AsyncAnalysisUpdate

            case Sldv.Tasking.SldvEvents.AsyncAnalysisDone
                assert(Sldv.Analysis.StrategyState.AsyncRunning==obj.mStrategyState);
                try
                    obj.mStrategyState=obj.mAnalysisStrategy.finishAsyncSolver();
                catch MEx
                    obj.done();
                    return;
                end

                if(true==obj.mAnalysisStrategy.isDone())
                    obj.done();
                    return;
                end

                obj.solveNext();

            case Sldv.Tasking.SldvEvents.SyncAnalysisDone
                assert(Sldv.Analysis.StrategyState.SyncDone==obj.mStrategyState);
                if(true==obj.mAnalysisStrategy.isDone())
                    obj.done();
                    return;
                end

                obj.solveNext();

            otherwise
                assert(false,'AnalysisTask received an invalid event');
            end

            return;
        end

        function doCleanup(obj,cause)
            if strcmp('DV_CAUSE_TIMEOUT',cause)||strcmp('DV_CAUSE_INTERRUPTED',cause)
                obj.mAnalysisStrategy.terminate(cause);
            end
            obj.mTaskManagerH.broadcastEvent(Sldv.Tasking.SldvEvents.AnalysisWrap);

            return;
        end
    end

    methods(Access=private)
        function solveNext(obj)
            try
                obj.mStrategyState=obj.mAnalysisStrategy.solveNext();
            catch MEx
                obj.done();
                return;
            end

            if(Sldv.Analysis.StrategyState.Failed==obj.mStrategyState)
                obj.done();
            elseif(Sldv.Analysis.StrategyState.SyncDone==obj.mStrategyState)
                obj.yield(Sldv.Tasking.SldvEvents.SyncAnalysisDone);
            end

            return;
        end
    end

end
