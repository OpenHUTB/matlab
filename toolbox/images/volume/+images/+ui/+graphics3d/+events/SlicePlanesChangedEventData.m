classdef(ConstructOnLoad)SlicePlanesChangedEventData<event.EventData




    properties

SlicePlanes

PreviousSlicePlanes

    end

    methods

        function evt=SlicePlanesChangedEventData(planes,oldPlanes)

            evt.SlicePlanes=planes;

            evt.PreviousSlicePlanes=oldPlanes;

        end

    end

end