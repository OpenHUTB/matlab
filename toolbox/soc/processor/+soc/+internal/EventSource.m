classdef EventSource<handle




    properties(SetAccess=protected,GetAccess=protected)
        TaskName='';
        ModelName='';
        CommType='pull';
        EventID='';
        EventHasCallback=false;
        DropOverranTasks=false;
        LogDroppedTasks=false;
        DurationFromDiagnostics=false;
        DiagnosticsFileName='';
        StartTime=0.0;
        EventViewer;
    end
    methods(Access=protected)
        function createTaskEventViewer(h,eventPostfix)


            sigName=[h.TaskName,eventPostfix];

            h.EventViewer=soc.profiler.ToAsyncQueueSignalView(h.ModelName,...
            sigName,zeros(1,1,'int32'),0,true,0);
        end
    end
    methods(Access=public)
        function eventID=getEventID(h)
            eventID=h.EventID;
        end

        function setModelName(h,value)
            h.ModelName=value;
        end

        function value=getModelName(h)
            value=h.ModelName;
        end

        function value=getTaskName(h)
            value=h.TaskName;
        end

        function setTaskName(h,value)
            h.TaskName=value;
        end

        function setCommType(h,value)
            h.CommType=value;
        end

        function value=getCommType(h)
            value=h.CommType;
        end

        function value=getLogDroppedTasks(h)
            value=h.LogDroppedTasks;
        end

        function setLogDroppedTasks(h,value)
            h.LogDroppedTasks=value;
        end

        function value=getDropOverranTasks(h)
            value=h.DropOverranTasks;
        end

        function setDropOverranTasks(h,value)
            h.DropOverranTasks=value;
        end

        function logDroppedTaskEvent(h,time)
            if(h.LogDroppedTasks)

                h.getEventViewer.update(cast(1,'int32'),int64(time*1e9));
            end
        end

        function setStartTime(h,value)%#ok<INUSD>

        end
    end
    methods(Access=public)
        function dropPastEvents(h,~,~)%#ok<INUSD>

        end
        function event=getNextEvent(h,eventID,time)%#ok<INUSD>
            event.ID=h.EventID;
            event.Time=Inf;
            event.TaskDuration=0;
            event.IsDurationFromDiagnostics=false;
        end
        function viwer=getEventViewer(h)
            viwer=h.EventViewer;
        end
    end
end
