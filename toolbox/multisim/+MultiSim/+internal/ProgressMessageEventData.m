




classdef ProgressMessageEventData<event.EventData
    properties
Message
Time
    end

    methods
        function data=ProgressMessageEventData(msg)
            data.Message=msg;
            data.Time=datestr(now);
        end
    end
end