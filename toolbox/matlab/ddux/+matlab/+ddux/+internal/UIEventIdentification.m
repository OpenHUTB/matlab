classdef UIEventIdentification<matlab.ddux.internal.Identification



    properties

        Scope(1,1)string;


        EventType(1,1)matlab.ddux.internal.EventType;


        ElementType(1,1)matlab.ddux.internal.ElementType;


        ElementId(1,1)string;
    end

    methods
        function obj=UIEventIdentification(product,scope,eventType,elementType,elementId)
            obj=obj@matlab.ddux.internal.Identification(product);
            obj.Scope=scope;
            obj.EventType=eventType;
            obj.ElementType=elementType;
            obj.ElementId=elementId;
        end
    end
end

