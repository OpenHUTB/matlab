classdef DiagnosticsEventSource<soc.internal.EventSource




    properties(SetAccess=private,GetAccess=private)
        Fid;
        Ctr;
        Data;
        LenData;
        MyTime;
        MyDuration;
        NoDataLeft=false;
        LoadingSize=100;
    end
    methods(Access=private)
        function loadMoreTaskDataAndResetCtr(h)
            h.Data=textscan(h.Fid,'%f, %f',h.LoadingSize);




            h.LenData=length(h.Data{2});
            h.NoDataLeft=isequal(h.LenData,0);
            if~h.NoDataLeft
                h.Ctr=1;
            end
        end
        function preloadTaskData(h)
            h.loadMoreTaskDataAndResetCtr;
            if h.NoDataLeft,return;end
            myCtr=h.Ctr;
            event.Time=h.Data{1}(myCtr);
            event.TaskDuration=h.Data{2}(myCtr);
            while((event.Time<h.StartTime)&&(~h.NoDataLeft)&&...
                ~isequal(event.Time,-1)&&~isequal(event.TaskDuration,-1))
                myCtr=myCtr+1;
                if(myCtr>h.LenData)
                    h.loadMoreTaskDataAndResetCtr;
                    if h.NoDataLeft
                        h.NoDataLeft=false;
                        h.Data{1}(h.Ctr)=event.Time;
                        h.Data{2}(h.Ctr)=event.TaskDuration;
                        h.LenData=1;
                        myCtr=h.Ctr;
                        break;
                    end
                    myCtr=h.Ctr;
                end
                event.Time=h.Data{1}(myCtr);
                event.TaskDuration=h.Data{2}(myCtr);
            end
            h.Ctr=myCtr;
        end
        function event=setLastEvent(h)
            event.ID=h.EventID;
            event.IsDurationFromDiagnostics=true;
            event.Time=Inf;
            event.TaskDuration=0;
        end
    end
    methods(Access=public)
        function delete(h)
            fclose(h.Fid);
            h.Data=[];
        end

        function setStartTime(h,value)
            h.StartTime=value;
        end

        function h=DiagnosticsEventSource(eventID,fileName,...
            modelName,taskName,dropOverranTasks,logDroppedTasks,...
            startTime)

            h.EventID=eventID;
            h.ModelName=modelName;
            h.TaskName=taskName;
            h.DropOverranTasks=dropOverranTasks;
            h.LogDroppedTasks=logDroppedTasks;
            h.StartTime=startTime;

            h.LenData=0;
            h.Ctr=1;

            [h.Fid,msg]=fopen(fileName);
            if isequal(h.Fid,-1)
                error(message('soc:scheduler:DiagFileOpenFailed',...
                fileName,msg));
            end

            if(h.LogDroppedTasks)
                postfix=...
                DAStudio.message('soc:scheduler:LogDroppedPostfix');
                h.createTaskEventViewer(postfix);
            end
            h.preloadTaskData;
        end

        function event=getNextEvent(h,~,time)
            if h.NoDataLeft,event=h.setLastEvent;return;end
            event.ID=h.EventID;
            event.IsDurationFromDiagnostics=true;
            event.Time=h.Data{1}(h.Ctr);
            event.TaskDuration=h.Data{2}(h.Ctr);
            while((event.Time<time)&&h.DropOverranTasks)||...
                (isequal(event.Time,-1)||isequal(event.TaskDuration,-1))
                if(h.LogDroppedTasks)&&...
                    ~(isequal(event.Time,-1)||isequal(event.TaskDuration,-1))


                    h.getEventViewer.update(cast(1,'int32'),int64(event.Time*1e9));
                end

                h.Ctr=h.Ctr+1;
                if(h.Ctr>h.LenData)
                    h.loadMoreTaskDataAndResetCtr;
                    if h.NoDataLeft,event=h.setLastEvent;return;end
                end
                event.Time=h.Data{1}(h.Ctr);
                event.TaskDuration=h.Data{2}(h.Ctr);
            end
            h.Ctr=h.Ctr+1;
            if(h.Ctr>h.LenData)
                h.loadMoreTaskDataAndResetCtr;
            end
        end
    end
end


