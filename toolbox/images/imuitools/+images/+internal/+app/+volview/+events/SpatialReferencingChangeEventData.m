

classdef(ConstructOnLoad)SpatialReferencingChangeEventData<event.EventData
    properties
Transform
ValidSpatialReferencingInFile

XYSlice
XZSlice
YZSlice

NumSlicesInX
NumSlicesInY
NumSlicesInZ

XSliceLocationSelected
YSliceLocationSelected
ZSliceLocationSelected
    end

    methods

        function data=SpatialReferencingChangeEventData(tform,xySlice,xzSlice,yzSlice,...
            numSlicesX,numSlicesY,numSlicesZ,xSliceSelected,ySliceSelected,zSliceSelected,validSpatialRefInFile)

            data.Transform=tform;

            [data.XYSlice,data.XZSlice,data.YZSlice]=deal(xySlice,xzSlice,yzSlice);
            [data.NumSlicesInX,data.NumSlicesInY,data.NumSlicesInZ]=deal(numSlicesX,numSlicesY,numSlicesZ);
            [data.XSliceLocationSelected,data.YSliceLocationSelected,data.ZSliceLocationSelected]=deal(xSliceSelected,ySliceSelected,zSliceSelected);

            data.ValidSpatialReferencingInFile=validSpatialRefInFile;

        end

    end
end