classdef(ConstructOnLoad)VariableEventData<event.EventData





    properties
Name
Value
Data
    end

    methods
        function eventObj=VariableEventData(Name,Value,varargin)
            eventObj.Name=Name;
            eventObj.Value=Value;
            if~isempty(varargin)
                eventObj.Data=varargin{1};
            end
        end

    end
end

