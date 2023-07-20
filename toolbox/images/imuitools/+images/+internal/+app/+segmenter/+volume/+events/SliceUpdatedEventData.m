classdef(ConstructOnLoad)SliceUpdatedEventData<event.EventData





    properties

VolumeSlice
LabelSlice

CurrentSlice
MaxSlice

Colormap
Alphamap

    end

    methods

        function data=SliceUpdatedEventData(vol,label,cmap,amap,idx,maxidx)

            data.VolumeSlice=vol;
            data.LabelSlice=label;
            data.Colormap=cmap;
            data.Alphamap=amap;
            data.CurrentSlice=idx;
            data.MaxSlice=maxidx;

        end

    end

end