function quantizationInfo=createCnnIR(networkInfo,...
    networkname,...
    codegenParams,...
    dlConfig,...
    activationLayerIndices,...
    activationPortIndices,...
    rowMajorCustomLayerIndices,...
    dlCodegenOptionsCallback,...
    networkWrapperIdentifier)























    assert(isa(networkInfo,'dltargets.internal.NetworkInfo'),'Expected a networkInfo Object');

    assert(numel(networkInfo.CodegenInputSizes)>0);

    codegendir=codegenParams.buildDir;
    targetType=codegenParams.targetType;

    dlCodegenOptionsCallback=char(dlCodegenOptionsCallback);

    batchSize=networkInfo.CodegenInputSizes{1}(end);
    validateBatchSize(dlConfig.TargetLibrary,batchSize);






    quantizationInfo=dltargets.internal.createQuantizerInfo(networkInfo,dlConfig);


    transformProperties=dltargets.internal.TransformProperties(networkInfo,activationLayerIndices);


    rowMajorCustomLayerNames=iGetRowMajorCustomLayerNames(rowMajorCustomLayerIndices,networkInfo.SortedLayers);


    networkFileSaver=dltargets.internal.NetworkFileSaver(networkInfo,networkWrapperIdentifier);
    networkFileSaver.generateNetworkInfoFile(networkname,dlConfig,codegendir,...
    targetType,rowMajorCustomLayerNames,...
    activationLayerIndices,...
    activationPortIndices,...
    iGetQuantizationSpecificationType(quantizationInfo,...
    dlCodegenOptionsCallback,dlConfig));


    networkInfo=dltargets.internal.optimizations.optimizeNetwork(networkInfo,dlConfig,transformProperties);


    dltargets.internal.cnnbuildpir(networkInfo,...
    networkname,...
    codegendir,...
    targetType,...
    dlConfig,...
    transformProperties,...
    rowMajorCustomLayerNames,...
    dlCodegenOptionsCallback);

end

function validateBatchSize(targetLib,batchSize)
    if batchSize>1
        if(strcmp(targetLib,'arm-compute-mali'))||strcmp(targetLib,'cmsis-nn')||...
            (strcmp(targetLib,'arm-compute')&&~dlcoderfeature('BatchSizeSupportForARMCompute'))
            error(message('gpucoder:cnnconfig:UnsupportedBatchSize',targetLib));
        end
    end
end

function rowMajorCustomLayerNames=iGetRowMajorCustomLayerNames(rowMajorCustomLayerIndices,layers)
    if rowMajorCustomLayerIndices==-1
        rowMajorCustomLayerNames={};
    else
        rowMajorCustomLayerNames=arrayfun(@(index)layers(index).Name,rowMajorCustomLayerIndices,'UniformOutput',false);
    end
end

function quantizationSpecificationType=iGetQuantizationSpecificationType(quantizationInfo,dlCodegenOptionsCallback,dlcfg)







    if~isempty(dlCodegenOptionsCallback)
        quantizationSpecificationType='global';
    elseif quantizationInfo.quantizedDLNetwork
        quantizationSpecificationType='local';
    elseif~isempty(quantizationInfo.exponentsData)
        quantizationSpecificationType='global';
    elseif isprop(dlcfg,'DataType')&&...
        (strcmpi(dlcfg.DataType,'int8'))
        quantizationSpecificationType='global';
    else
        quantizationSpecificationType='none';
    end
end
