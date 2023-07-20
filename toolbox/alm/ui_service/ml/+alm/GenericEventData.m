classdef GenericEventData<event.EventData
    properties
EventType
ProjectRoot
Payload
    end

    methods
        function obj=GenericEventData(eventType,projectRoot,payload)
            obj.EventType=eventType;
            obj.ProjectRoot=projectRoot;
            obj.Payload=payload;
        end
    end
end