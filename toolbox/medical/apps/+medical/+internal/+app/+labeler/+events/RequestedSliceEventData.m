classdef(ConstructOnLoad)RequestedSliceEventData<event.EventData




    properties

Slice
LabelSlice

CurrentIdx
MaxIdx
LabelColormap
LabelVisible

SliceDirection

    end

    methods

        function data=RequestedSliceEventData(slice,labelSlice,currIdx,maxIdx,labelColormap,labelVisible,sliceDirection)

            data.Slice=slice;
            data.LabelSlice=labelSlice;

            data.CurrentIdx=currIdx;
            data.MaxIdx=maxIdx;
            data.LabelColormap=labelColormap;
            data.LabelVisible=labelVisible;

            data.SliceDirection=sliceDirection;

        end

    end

end