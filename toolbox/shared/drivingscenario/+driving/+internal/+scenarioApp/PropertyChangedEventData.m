classdef PropertyChangedEventData<event.EventData


    properties
Specification
Property
    end

    methods
        function this=PropertyChangedEventData(spec,propName)
            this.Specification=spec;
            this.Property=propName;
        end
    end
end


