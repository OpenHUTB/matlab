classdef(ConstructOnLoad)ExternalTriggerEventData<event.EventData





    properties

        ExternalTriggerType;

        ExternalTriggerData;

    end

    methods
        function data=ExternalTriggerEventData(type,triggerData)
            data.ExternalTriggerType=type;
            if nargin==2
                data.ExternalTriggerData=triggerData;
            end
        end
    end

end