function layer=getFusedLayer(obj,layerIdx,activationLayerIndices,fusedLayerOffsetIndices)













%#codegen
%#internal
    coder.allowpcode('plain');
    coder.inline("always");

    coder.internal.prefer_const(layerIdx);

    layer=getLayer(obj,layerIdx);


    matchesActivationLayerIndices=(activationLayerIndices==layerIdx);
    if any(matchesActivationLayerIndices)&&isa(layer,'coder.internal.layer.FusedLayer')
        layer.ActivationLayerOffset=fusedLayerOffsetIndices(matchesActivationLayerIndices);
    end

end
