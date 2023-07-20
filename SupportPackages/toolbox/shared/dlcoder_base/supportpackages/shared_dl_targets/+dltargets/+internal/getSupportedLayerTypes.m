





function layerTypes=getSupportedLayerTypes(targetname)
    target=dltargets.internal.translateTargetName(targetname);

    if strcmp(target,'none')
        supportedLayersForTargetMapInfo=coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.LayerToBuilderMap;
        if dlcoderfeature("EnableCustomLayerPrototypes")
            supportedLayersForTargetMapInfo=[supportedLayersForTargetMapInfo;...
            coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.PrototypedLayerToBuilderMap];
        end
        layerTypes=keys(supportedLayersForTargetMapInfo);


        layerTypes=filterLayers(layerTypes,targetname);
    elseif strcmp(target,'cmsis_nn')
        implPackage=['dltargets.',target];
        layerToCompMap=eval([implPackage,'.SupportedLayerImpl.m_layerToCompMap']);
        layerTypes=keys(layerToCompMap);
    else
        layerToCompMapInfo=dltargets.internal.LayerToCompMapInfo();
        layerToCompMap=layerToCompMapInfo.getLayersToCompMap();
        layerTypes=keys(layerToCompMap);


        implPackage=['dltargets.',target];
        supportedCompForTarget=eval([implPackage,'.SupportedLayerImpl.m_sourceFiles']);
        layerIdxs=cellfun(@(x)isKey(supportedCompForTarget,layerToCompMap(x)),layerTypes);
        layerTypes=layerTypes(layerIdxs);


        layerTypes=filterLayers(layerTypes,targetname);
    end
end

function layerTypes=filterLayers(layerTypes,targetname)

    filteredOutLayers={};


    biLSTMSupportedTargets={'cudnn','tensorrt','arm-compute','mkldnn','onednn','none'};
    if~any(strcmpi(targetname,biLSTMSupportedTargets))
        filteredOutLayers=[filteredOutLayers,{'nnet.cnn.layer.BiLSTMLayer'}];
    end


    GRUSupportedTargets={'cudnn','tensorrt','arm-compute','mkldnn','onednn','none'};
    if~any(strcmpi(targetname,GRUSupportedTargets))
        filteredOutLayers=[filteredOutLayers,{'nnet.cnn.layer.GRULayer'}];
    end


    concatenationSupportedTargets={'cudnn','tensorrt','arm-compute','mkldnn','onednn','none'};
    if~any(strcmpi(targetname,concatenationSupportedTargets))
        filteredOutLayers=[filteredOutLayers,{'nnet.cnn.layer.ConcatenationLayer'}];
    end


    foldingSupportedTargets={'cudnn','tensorrt','arm-compute','mkldnn','onednn'};
    if~any(strcmpi(targetname,foldingSupportedTargets))
        filteredOutLayers=[filteredOutLayers,{'nnet.cnn.layer.SequenceFoldingLayer'}];
    end


    unfoldingSupportedTargets={'cudnn','tensorrt','arm-compute','mkldnn','onednn'};
    if~any(strcmpi(targetname,unfoldingSupportedTargets))
        filteredOutLayers=[filteredOutLayers,{'nnet.cnn.layer.SequenceUnfoldingLayer'}];
    end

    layerTypes=setdiff(layerTypes,filteredOutLayers);

end
