classdef LaneMarkerDeletedEvent<event.EventData
    properties
WasSelected
    end

    methods
        function this=LaneMarkerDeletedEvent(wasSelected)
            this.WasSelected=wasSelected;
        end
    end
end