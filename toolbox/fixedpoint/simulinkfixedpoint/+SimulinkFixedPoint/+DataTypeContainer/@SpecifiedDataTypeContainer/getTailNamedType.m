function tailNamedType=getTailNamedType(this)







    resolutionQueue=getResolutionQueueForNamedType(this);
    tailNamedType=resolutionQueue{end};
end


