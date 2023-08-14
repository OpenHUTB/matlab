function plotMapping=createPlotMapping(axesMapping,locInOldCacheExpanded,oldCumLengths,inOldCache,getVariableByCacheIndex)






    plotMapping=zeros(size(axesMapping));
    for i=1:length(plotMapping)
        if inOldCache(i)
            npreviousVarsInOldAxes=locInOldCacheExpanded(i)-oldCumLengths(axesMapping(i))-1;
            npreviousPlotsInOldAxes=0;
            idxPrevMin=locInOldCacheExpanded(i)-npreviousVarsInOldAxes;
            idxPrevMax=locInOldCacheExpanded(i)-1;
            for j=idxPrevMin:idxPrevMax

                arr=getVariableByCacheIndex(j);
                npreviousPlotsInOldAxes=npreviousPlotsInOldAxes+size(arr(:,:),2);
            end
            plotMapping(i)=npreviousPlotsInOldAxes+1;
        end
    end