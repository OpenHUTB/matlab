classdef(ConstructOnLoad)ROIShowLabelsEventData<event.EventData

    properties
ShowLabels
    end

    methods
        function eventData=ROIShowLabelsEventData(show)
            eventData.ShowLabels=show;
        end
    end
end