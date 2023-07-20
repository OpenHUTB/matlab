classdef(ConstructOnLoad)SpatialReferencingChangedEventData<event.EventData





    properties

X
Y
Z

    end

    methods

        function data=SpatialReferencingChangedEventData(x,y,z)

            data.X=x;
            data.Y=y;
            data.Z=z;

        end

    end

end