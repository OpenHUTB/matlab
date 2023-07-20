function cache=cacheArchitectureData(blkHandle)







    portBlockHandles=[];
    cache.bridgeData=get_param(bdroot(blkHandle),'SimulinkArchBridgeData');
    cache.blkSID=cache.bridgeData.getSIDFromBlockHandle(blkHandle);
    if(strcmp(get_param(blkHandle,'BlockType'),'SubSystem'))
        f=Simulink.FindOptions('SearchDepth',1);
        portBlockHandles=[...
        Simulink.findBlocksOfType(blkHandle,'Inport',f);...
        Simulink.findBlocksOfType(blkHandle,'Outport',f)];
    end
    portSIDs=zeros(1,numel(portBlockHandles));
    for idx=1:numel(portBlockHandles)
        portSIDs(idx)=cache.bridgeData.getSIDFromBlockHandle(portBlockHandles(idx));
    end
    cache.portSIDs=portSIDs;



    cache.blkConnMapBefore=systemcomposer.internal.arch.internal.ZCUtils.GetConnectionMapping(blkHandle);

end
