classdef Idler<handle









    methods

        function obj=Idler()

            obj.TimedOut=false;
            obj.Status=false;
        end

        function status=startIdling(obj,maxIdleTime)






            timerFcn=@(~,~)(obj.timedOut());
            timerObj=timer('StartDelay',maxIdleTime,...
            'TimerFcn',timerFcn,'ExecutionMode','singleShot');
            cleanObj=onCleanup(@()delete(timerObj));
            start(timerObj);
            if~obj.Status
                waitfor(obj,'Status',true)
            end
            stop(timerObj);

            status=obj.Status&&(~obj.TimedOut);
        end

        function stopIdling(obj)

            obj.Status=true;
        end

    end

    properties(Hidden)
Status
TimedOut
    end

    methods(Hidden)

        function timedOut(obj)
            obj.TimedOut=true;
            obj.Status=true;
        end


    end
end
