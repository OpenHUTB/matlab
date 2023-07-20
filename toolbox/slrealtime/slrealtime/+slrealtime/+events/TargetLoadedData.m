classdef TargetLoadedData<event.EventData




    properties
StopTime
IsReloadOnStop
    end

    methods
        function data=TargetLoadedData(stoptime,isReloadOnStop)
            data.StopTime=stoptime;
            data.IsReloadOnStop=isReloadOnStop;
        end
    end
end
