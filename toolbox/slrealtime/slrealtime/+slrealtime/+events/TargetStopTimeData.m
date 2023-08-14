classdef TargetStopTimeData<event.EventData




    properties
stoptime
    end

    methods
        function data=TargetStopTimeData(stoptime)
            data.stoptime=stoptime;
        end
    end
end
