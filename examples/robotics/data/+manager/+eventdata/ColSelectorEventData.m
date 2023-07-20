classdef(ConstructOnLoad)ColSelectorEventData<event.EventData



    properties
SelectorValues
    end

    methods
        function eventData=ColSelectorEventData(north,east,south,west)
            eventData.SelectorValues.North=north;
            eventData.SelectorValues.East=east;
            eventData.SelectorValues.South=south;
            eventData.SelectorValues.West=west;
        end
    end
end

