classdef(ConstructOnLoad)AsyncHTTPContentEventData<event.EventData

    properties
Status
    end

    methods
        function data=AsyncHTTPContentEventData(status)
            data.Status=status;
        end
    end
end

