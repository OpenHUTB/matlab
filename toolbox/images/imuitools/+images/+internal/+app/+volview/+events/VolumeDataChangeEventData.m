




classdef(ConstructOnLoad)VolumeDataChangeEventData<event.EventData
    properties
Volume
OverlayVolume
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
VolumeSize
TransformedVolumeSize
    end

    methods
        function data=VolumeDataChangeEventData(volumeData,overlayData,xySlice,xzSlice,...
            yzSlice,numSlicesInX,numSlicesInY,numSlicesInZ,...
            xSliceLocation,ySliceLocation,zSliceLocation,isLogicalData,...
            hasVolume,hasLabeledVolume,VolumeDisplayMode,volSize,tformedVolSize)

            data.Volume=volumeData;
            data.OverlayVolume=overlayData;
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
            data.VolumeSize=volSize;
            data.TransformedVolumeSize=tformedVolSize;
        end
    end
end
