




classdef JobQueue<handle























    properties
        queue={};
        isLocked=false;

        jobTimer=[];
        jobTimerListener=[];
    end

    methods
        function delete(obj)
            obj.stop;
        end

        function enqueue(obj,job,front)
            if front
                obj.queue=[{job},obj.queue];
            else
                obj.queue{end+1}=job;
            end
        end






        function processOne(obj,~,~)
            if~obj.isLocked&&~isempty(obj.queue)




                obj.isLocked=true;

                job=obj.queue{1};
                obj.queue=obj.queue(2:end);

                try
                    job.run();
                catch err
                    obj.isLocked=false;

                    MSLDiagnostic(err).reportAsWarning;
                end
                obj.isLocked=false;
            end
        end

        function start(obj)
            if isempty(obj.jobTimer)





                obj.jobTimer=internal.IntervalTimer(0.5);
                obj.jobTimerListener=event.listener(obj.jobTimer,'Executing',@(src,evt)obj.processOne());

                start(obj.jobTimer);
            end
        end



        function stop(obj)
            if~isempty(obj.jobTimer)

                clear('obj.jobTimerListener');
                obj.jobTimerListener=[];


                stop(obj.jobTimer);
                clear('obj.jobTimer');
                obj.jobTimer=[];
            end
        end

        function flush(obj)
            obj.queue={};
        end
    end
end

