


classdef ProgressUITask<Sldv.Tasking.Task
    properties
        mTestComp=[];
isValidatorON
    end

    methods
        function obj=ProgressUITask(aTaskMgrH,aReady,aTestComp)

            obj=obj@Sldv.Tasking.Task(aTaskMgrH,aReady);

            obj.mTestComp=aTestComp;



            obj.isValidatorON=Sldv.Utils.isValidatorEnabled(aTestComp.activeSettings,aTestComp.simMode);
            if obj.isValidatorON
                obj.connect(Sldv.Tasking.SldvChannels.ValidatedGoals,...
                Sldv.Tasking.ChannelConnectMode.Read);
            else
                obj.connect(Sldv.Tasking.SldvChannels.ProcessedGoals,...
                Sldv.Tasking.ChannelConnectMode.Read);
            end
        end

        function delete(~)
        end

    end

    methods(Access=protected)
        function status=doTask(obj,aEvent)

            assert(~isempty(obj.mTestComp),'Not a valid testcomponent');

            status=true;
            switch aEvent
            case Sldv.Tasking.SldvChannels.ProcessedGoals
                assert(~obj.isValidatorON,'Invalid Event');
                status=obj.evaluateProcessedGoals(aEvent);

            case Sldv.Tasking.SldvChannels.ValidatedGoals
                assert(obj.isValidatorON,'Invalid Event');
                status=obj.evaluateValidatedGoals(aEvent);

            otherwise
                assert(false,'ProgressUI Task received an invalid event');
            end

            return;
        end

        function doCleanup(obj,cause)
            obj.flush();

            return;
        end

        function flush(obj)
            if obj.isValidatorON
                obj.evaluateValidatedGoals('FLUSH');
            else
                obj.evaluateProcessedGoals('FLUSH');
            end

            return;
        end

    end

    methods(Access=private)
        function updateProgressUI(obj,goalIds)
            testComp=obj.mTestComp;
            tGoalUDIs=arrayfun(@(g)testComp.getGoal(g),goalIds);
            slavteng_result_callback(testComp,tGoalUDIs);
            jnk=[];
            slavteng_activity_callback(testComp,jnk);

            return;
        end

        function status=evaluateProcessedGoals(obj,aEvent)
            status=true;




            if(obj.isEof(Sldv.Tasking.SldvChannels.ProcessedGoals))
                obj.done();
                return;
            end


            [status,goalIds,~]=obj.read(Sldv.Tasking.SldvChannels.ProcessedGoals);
            assert(status,'Unable to read from Processed Channel');

            obj.logGoals(goalIds,aEvent);


            obj.updateProgressUI(goalIds);

            return;
        end

        function status=evaluateValidatedGoals(obj,aEvent)
            status=true;




            if(obj.isEof(Sldv.Tasking.SldvChannels.ValidatedGoals))
                obj.done();
                return;
            end


            [status,goalIds,~]=obj.read(Sldv.Tasking.SldvChannels.ValidatedGoals);
            assert(status,'Unable to read from Validated Goals Channel');

            obj.logGoals(goalIds,aEvent);


            obj.updateProgressUI(goalIds);

            return;
        end

        function logGoals(obj,goalIds,msgIdentifier)
            LoggerId='sldv::task_manager';
            logStr=sprintf('ProgressUITask::%s::Start Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);

            testComp=obj.mTestComp;
            for ind=1:numel(goalIds)
                goalStatus=testComp.getGoal(goalIds(ind)).status;
                logStr=sprintf('ProgressUITask::%s::Goal::Id::%d::Status::%s',msgIdentifier,goalIds(ind),goalStatus);
                sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);
            end
            logStr=sprintf('ProgressUITask::%s::End Logging',msgIdentifier);
            sldvprivate('SLDV_LOG_DATA',LoggerId,logStr);

            return;
        end
    end

end
