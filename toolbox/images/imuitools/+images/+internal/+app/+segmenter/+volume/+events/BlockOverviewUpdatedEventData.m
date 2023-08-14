classdef(ConstructOnLoad)BlockOverviewUpdatedEventData<event.EventData





    properties

Data
Completed
History
CurrentIndex
BlockSize
Colormap
Alphamap
SizeInBlocks

    end

    methods

        function data=BlockOverviewUpdatedEventData(vol,completedBlocks,his,idx,sz,cmap,amap,sizeInBlocks)

            data.Data=vol;
            data.Completed=completedBlocks;
            data.History=his;
            data.CurrentIndex=idx;
            data.BlockSize=sz;
            data.Colormap=cmap;
            data.Alphamap=amap;
            data.SizeInBlocks=sizeInBlocks;

        end

    end

end