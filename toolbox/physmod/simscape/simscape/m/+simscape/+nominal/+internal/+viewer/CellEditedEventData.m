





classdef(ConstructOnLoad)CellEditedEventData<event.EventData
    properties
Indices
PreviousData
    end

    methods
        function data=CellEditedEventData(idx,previousdata)
            data.Indices=idx;
            data.PreviousData=previousdata;
        end
    end
end