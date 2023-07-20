classdef(ConstructOnLoad)ClippingPlanesChangedEventData<event.EventData




    properties

ClippingPlanes

PreviousClippingPlanes

    end

    methods

        function evt=ClippingPlanesChangedEventData(planes,oldPlanes)

            evt.ClippingPlanes=planes;

            evt.PreviousClippingPlanes=oldPlanes;

        end

    end

end