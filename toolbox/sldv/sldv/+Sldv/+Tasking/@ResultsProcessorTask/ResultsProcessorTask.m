















classdef ResultsProcessorTask<Sldv.Tasking.Task

    properties(Access=private)
        mSldvAnalyzer=[];
        mTaskManager=[];
    end


    methods(Access=public)
        function obj=ResultsProcessorTask(aTaskMgH,aReady,aSldvAnalyzer)
            obj=obj@Sldv.Tasking.Task(aTaskMgH,aReady);
            obj.mTaskManager=aTaskMgH;





            obj.triggerOn(Sldv.Tasking.SldvEvents.AsyncAnalysisLaunched);
            obj.triggerOn(Sldv.Tasking.SldvEvents.AsyncAnalysisUpdate);
            obj.triggerOn(Sldv.Tasking.SldvEvents.AnalysisWrap);
            obj.triggerOn(Sldv.Tasking.SldvEvents.ResultsPoll);


            obj.connect(Sldv.Tasking.SldvChannels.ProcessedGoals,...
            Sldv.Tasking.ChannelConnectMode.Write);
            obj.connect(Sldv.Tasking.SldvChannels.ProcessedTestCases,...
            Sldv.Tasking.ChannelConnectMode.Write);

            obj.mSldvAnalyzer=aSldvAnalyzer;
        end

        function delete(~)
        end

    end


    methods(Access=protected)
        function status=doTask(obj,aEvent)

            assert(~isempty(obj.mSldvAnalyzer)&&isvalid(obj.mSldvAnalyzer));

            status=true;
            switch aEvent
            case Sldv.Tasking.SldvEvents.AsyncAnalysisLaunched
                obj.readResults(aEvent);
                if slavteng('feature','ResultsPolling')==1
                    is_done=obj.checkAndHandleAnalysisDone();
                    if is_done
                        LoggerId='sldv::task_manager';
                        logStr=sprintf('ResultProcessorTask::doTask::done');
                        sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
                        return;
                    end
                    LoggerId='sldv::task_manager';
                    logStr=sprintf('ResultProcessorTask::doTask::raise ResultsPoll event');
                    sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
                    obj.yield(Sldv.Tasking.SldvEvents.ResultsPoll);
                end

            case Sldv.Tasking.SldvEvents.AsyncAnalysisUpdate
                obj.readResults(aEvent);

            case Sldv.Tasking.SldvEvents.ResultsPoll
                obj.readResults(aEvent);
                is_done=obj.checkAndHandleAnalysisDone();
                if is_done
                    LoggerId='sldv::task_manager';
                    logStr=sprintf('ResultProcessorTask::doTask::done');
                    sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
                    return;
                end
                LoggerId='sldv::task_manager';
                logStr=sprintf('ResultProcessorTask::doTask::raise ResultsPoll event');
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
                obj.yield(Sldv.Tasking.SldvEvents.ResultsPoll);

            case Sldv.Tasking.SldvEvents.AnalysisWrap



                obj.done();

            otherwise
                assert(false,'ResultsProcessorTask received an invalid event');
            end

            return;
        end

        function doCleanup(obj,cause)
            if(strcmp('DV_CAUSE_TIMEOUT',cause)||strcmp('DV_CAUSE_INTERRUPTED',cause))
                obj.readResults(cause);
            end


            obj.disConnect(Sldv.Tasking.SldvChannels.ProcessedGoals);
            obj.disConnect(Sldv.Tasking.SldvChannels.ProcessedTestCases);

            return;
        end

        function flush(~)

        end

        function readResults(obj,aEvent)

            LoggerId='sldv::task_manager';
            logStr=sprintf('ResultProcessorTask::readResults::Start Logging');
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            results=obj.mSldvAnalyzer.getAnalysisResults();
            logStr=sprintf('ResultProcessorTask::readResults::End Logging');
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);


            goalIds=results.goals;
            testCaseIds=results.testcases;


            if~isempty(goalIds)
                obj.write(Sldv.Tasking.SldvChannels.ProcessedGoals,goalIds);
            end
            if~isempty(testCaseIds)
                obj.write(Sldv.Tasking.SldvChannels.ProcessedTestCases,testCaseIds);
            end


            obj.logGoalsNTestCases(aEvent,goalIds,testCaseIds);

            return;
        end

        function logGoalsNTestCases(obj,msgIdentifier,goalIds,testCaseIds)
            LoggerId='sldv::task_manager';
            logStr=sprintf('ResultProcessorTask::%s::Start Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);


            for ind=1:numel(goalIds)
                logStr=sprintf('ResultProcessorTask::%s::Goal::Id::%d::Status::%s',msgIdentifier,goalIds(ind),obj.mSldvAnalyzer.getGoalStatus(goalIds(ind)));
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            end


            for ind=1:numel(testCaseIds)
                logStr=sprintf('ResultProcessorTask::%s::Testcase::Id::%d',msgIdentifier,testCaseIds(ind));
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            end
            logStr=sprintf('ResultProcessorTask::%s::End Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);

            return;
        end

        function is_done=checkAndHandleAnalysisDone(obj)
            is_done=false;








            if slfeature('SldvTaskingArchitecture')==1
                analysis_done=obj.mSldvAnalyzer.isAnalysisDone();
                if analysis_done
                    obj.mTaskManager.broadcastEvent(Sldv.Tasking.SldvEvents.AsyncAnalysisDone);
                    return;
                end
            end

        end


    end

end


