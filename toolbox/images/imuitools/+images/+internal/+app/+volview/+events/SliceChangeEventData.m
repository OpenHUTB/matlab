classdef(ConstructOnLoad)SliceChangeEventData<event.EventData
    properties
Slice
NumSlicesInDim
SliceIndex
VolumeSize
    end

    methods
        function data=SliceChangeEventData(sliceIn,numSlices,sliceIdx,volSize)
            data.Slice=sliceIn;
            data.NumSlicesInDim=numSlices;
            data.SliceIndex=sliceIdx;
            data.VolumeSize=volSize;
        end
    end
end