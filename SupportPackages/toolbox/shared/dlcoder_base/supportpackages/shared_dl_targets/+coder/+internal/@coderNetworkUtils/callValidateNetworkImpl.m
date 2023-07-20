









function callValidateNetworkImpl(dlnet,dlConfig,networkInfo)

    layerInfoMap=networkInfo.LayerInfoMap;
    isCnnCodegenWorkflow=false;
    dltargets.internal.sharedNetwork.validateNetworkImpl(dlnet,dlConfig,layerInfoMap,isCnnCodegenWorkflow)

end
