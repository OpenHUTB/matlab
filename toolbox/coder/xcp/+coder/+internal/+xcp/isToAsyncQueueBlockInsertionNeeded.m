function val=isToAsyncQueueBlockInsertionNeeded(mdl)







    isSLRT=strcmp(get_param(mdl,'IsSLRTTarget'),'on');

    val=isSLRT||coder.internal.xcp.isModelConfiguredForXCPExtMode(mdl);

end
