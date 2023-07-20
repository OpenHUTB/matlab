classdef(ConstructOnLoad)SpatialReferencingEditFieldsSetEventData<event.EventData
    properties
XSize
YSize
ZSize
    end

    methods
        function data=SpatialReferencingEditFieldsSetEventData(xSize,ySize,zSize)
            data.XSize=xSize;
            data.YSize=ySize;
            data.ZSize=zSize;
        end
    end
end
