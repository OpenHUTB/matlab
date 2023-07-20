function restoreArchitectureData(mdlHandle,cache,restoreConnections)






    mdlSID=get_param(mdlHandle,'SID');
    cache.bridgeData.updateBridgeDataMap(cache.blkSID,mdlSID,mdlHandle);


    for idx=1:numel(cache.portSIDs)
        cache.bridgeData.removeBlockHandleSIDPairBySID(cache.portSIDs(idx));
        cache.bridgeData.removeElemPairForSID(cache.portSIDs(idx));
    end


    if restoreConnections
        systemcomposer.internal.arch.internal.ZCUtils.ResolveConnections(mdlHandle,cache.blkConnMapBefore);
    end
end
