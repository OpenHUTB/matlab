


classdef LabelSetUpdateEvent<event.EventData
    properties
Label
OldLabel
Color
ROIVisibility
    end

    methods
        function this=LabelSetUpdateEvent(info)
            if ischar(info)
                this.Label=info;
            else
                this.Color=info;
            end
        end
    end
end