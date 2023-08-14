function[axesMapping,oldCumLengths]=createAxesMapping(oldNumVarsPerAxes,locInOldCacheExpanded)


















    oldCumLengths=[0;cumsum(oldNumVarsPerAxes(:))];




    axesMapping=sum(oldCumLengths<locInOldCacheExpanded(:)',1);