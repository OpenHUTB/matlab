

classdef(ConstructOnLoad)InputSourceUpdateEventData<event.EventData

    properties
InputSource
VolType
    end

    methods
        function obj=InputSourceUpdateEventData(source,voltype)
            obj.InputSource=source;
            obj.VolType=voltype;
        end
    end
end