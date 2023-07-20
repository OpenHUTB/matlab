function[values,names,propNames,blockPaths]=utGetMetadataForDisplay(this)



    fullyLoadCache(this);
    [values,names,propNames,blockPaths]=...
    utGetMetadataForDisplay(this.ElementCache);
end
