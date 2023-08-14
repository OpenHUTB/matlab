classdef HighlightChangeEventData<event.EventData





    properties
type
eventObj
    end

    methods
        function this=HighlightChangeEventData(type,eventObj)
            this.type=type;
            this.eventObj=eventObj;
        end
    end

end