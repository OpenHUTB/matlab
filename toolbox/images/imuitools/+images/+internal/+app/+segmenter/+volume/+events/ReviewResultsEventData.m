classdef(ConstructOnLoad)ReviewResultsEventData<event.EventData





    properties

BlockedVolume
BlockedLabels
Categories
Metrics
BlockFileNames
UseOriginalData
RedLimits
GreenLimits
BlueLimits
BlockMap
Colormap

    end

    methods

        function data=ReviewResultsEventData(bim,blabel,cats,metrics,blockFileNames,useOriginalData,blockMap,r,g,b,cmap)

            data.BlockedVolume=bim;
            data.BlockedLabels=blabel;
            data.Categories=cats;
            data.Metrics=metrics;
            data.BlockFileNames=blockFileNames;
            data.UseOriginalData=useOriginalData;
            data.BlockMap=blockMap;
            data.RedLimits=r;
            data.GreenLimits=g;
            data.BlueLimits=b;
            data.Colormap=cmap;

        end

    end

end