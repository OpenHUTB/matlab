classdef(ConstructOnLoad)SliceChangeEventData<event.EventData
    properties
Slice
NumSlicesInDim
SliceIndex
    end

    methods
        function data=SliceChangeEventData(sliceIn,numSlices,sliceIdx)
            data.Slice=sliceIn;
            data.NumSlicesInDim=numSlices;
            data.SliceIndex=sliceIdx;
        end
    end
end