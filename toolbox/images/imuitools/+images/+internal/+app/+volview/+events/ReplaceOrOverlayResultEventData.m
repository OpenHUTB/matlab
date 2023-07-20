

classdef(ConstructOnLoad)ReplaceOrOverlayResultEventData<event.EventData
    properties
RefreshValue
    end

    methods
        function obj=ReplaceOrOverlayResultEventData(refreshValue)
            obj.RefreshValue=refreshValue;
        end
    end
end