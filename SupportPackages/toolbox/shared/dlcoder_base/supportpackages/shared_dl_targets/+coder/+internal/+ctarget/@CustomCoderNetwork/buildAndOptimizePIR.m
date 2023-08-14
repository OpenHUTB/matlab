function layerComps=buildAndOptimizePIR(networkInfo,networkName,buildContext,dlConfig,...
    transformProperties,buildDirectory)

















    rowMajorCustomLayerNames={};
    tensorrtQuantSpec='';


    globalDnnContext=dltargets.internal.cnnbuildpir(networkInfo,...
    networkName,...
    buildDirectory,...
    buildContext.CodeGenTarget,...
    dlConfig,...
    transformProperties,...
    rowMajorCustomLayerNames,...
    tensorrtQuantSpec);

    batchSize=networkInfo.CodegenInputSizes{1}(4);
    quantizationInfo=dltargets.internal.createQuantizerInfo(networkInfo,dlConfig);








    activationPortIndices=-1.*ones(size(transformProperties.activationLayerIndices));
    globalDnnContext.invokeDnnBackendPostEmission(networkName,dlConfig,batchSize,...
    quantizationInfo,transformProperties.activationLayerIndices,activationPortIndices,networkInfo);


    pirNetwork=globalDnnContext.getTopNetwork;
    layerComps=pirNetwork.Components;

end
