classdef CodeViewEventData<event.EventData


    properties
data
    end

    methods
        function obj=CodeViewEventData(msg)

            obj.data=msg;
        end
    end
end

