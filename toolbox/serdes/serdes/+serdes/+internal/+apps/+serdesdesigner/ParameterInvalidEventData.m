classdef(ConstructOnLoad)ParameterInvalidEventData<event.EventData



    properties
Name
Value
    end

    methods
        function data=ParameterInvalidEventData(name,value)
            data.Name=name;
            data.Value=value;
        end
    end
end
