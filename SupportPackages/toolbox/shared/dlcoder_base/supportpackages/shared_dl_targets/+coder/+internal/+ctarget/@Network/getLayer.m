function layer=getLayer(obj,layerIdx)











%#codegen
%#internal
    coder.allowpcode('plain');
    coder.inline("always");

    coder.internal.prefer_const(layerIdx);

    if coder.const(obj.IsLayerTunable(layerIdx))
        layerIndices=1:numel(obj.TunableLayerIndices);
        storedLayerIdx=layerIndices(obj.TunableLayerIndices==layerIdx);
        layer=obj.TunableLayers{storedLayerIdx};
    else
        layer=coder.const(@feval,'getLayer',obj.DLCustomCoderNetwork,layerIdx);
    end

end
