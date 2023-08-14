




classdef(ConstructOnLoad)VolumeDataChangeEventData<event.EventData
    properties
Volume
XYSlice
YZSlice
XZSlice
NumSlicesInX
NumSlicesInY
NumSlicesInZ
XSliceLocationSelected
YSliceLocationSelected
ZSliceLocationSelected
IsLogicalData
HasVolumeData
HasLabeledVolumeData
VolumeDisplayMode
    end

    methods
        function data=VolumeDataChangeEventData(volumeData,xySlice,xzSlice,...
            yzSlice,numSlicesInX,numSlicesInY,numSlicesInZ,...
            xSliceLocation,ySliceLocation,zSliceLocation,isLogicalData,...
            hasVolume,hasLabeledVolume,VolumeDisplayMode)

            data.Volume=volumeData;
            data.XYSlice=xySlice;
            data.XZSlice=xzSlice;
            data.YZSlice=yzSlice;
            data.NumSlicesInX=numSlicesInX;
            data.NumSlicesInY=numSlicesInY;
            data.NumSlicesInZ=numSlicesInZ;
            data.XSliceLocationSelected=xSliceLocation;
            data.YSliceLocationSelected=ySliceLocation;
            data.ZSliceLocationSelected=zSliceLocation;
            data.IsLogicalData=isLogicalData;
            data.HasVolumeData=hasVolume;
            data.HasLabeledVolumeData=hasLabeledVolume;
            data.VolumeDisplayMode=VolumeDisplayMode;
        end
    end
end