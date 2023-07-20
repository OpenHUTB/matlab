classdef IOPeripheralEventSource<soc.internal.EventSource




    properties(SetAccess=private,GetAccess=private)
        BlockHandle=[];
        TaskFcnPollCmd='';
    end
    methods(Access=public)
        function setBlockHandle(h,blockHandle)
            h.BlockHandle=blockHandle;
        end

        function blockHandle=getBlockHandle(h)
            blockHandle=h.BlockHandle;
        end

        function setTaskFcnPollCmd(h,taskFcnPollCmd)
            h.TaskFcnPollCmd=taskFcnPollCmd;
        end

        function taskFcnPollCmd=getTaskFcnPollCmd(h)
            taskFcnPollCmd=h.TaskFcnPollCmd;
        end
    end
    methods(Access=public)
        function h=IOPeripheralEventSource(eventID,modelName,...
            taskName,dropOverranTasks,logDroppedTasks)

            h.EventID=eventID;
            h.ModelName=modelName;
            h.TaskName=taskName;
            h.DropOverranTasks=dropOverranTasks;
            h.LogDroppedTasks=logDroppedTasks;

            if(h.LogDroppedTasks)
                postfix=DAStudio.message('soc:scheduler:LogDroppedPostfix');
                h.createTaskEventViewer(postfix);
            end
        end

        function event=getNextEvent(h,eventID,time)
            event=h.BlockHandle.getNextEvent(eventID,time);
            if~isempty(event)
                event.TaskDuration=0;
                event.IsDurationFromDiagnostics=false;
            end
        end
    end
end