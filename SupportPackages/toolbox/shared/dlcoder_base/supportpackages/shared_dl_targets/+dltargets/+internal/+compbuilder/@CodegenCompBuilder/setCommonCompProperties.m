

function comp=setCommonCompProperties(layer,converter,comp)






    layerInfo=converter.getLayerInfo(layer.Name);


    dltargets.internal.setCompOutputDimensions(layerInfo.outputSizes,layerInfo.outputFormats,comp);


    idx=converter.transformProperties.getLayerIdxFromMap(layer);


    comp.setDLTActivationLayerIndex(int32(idx));
    comp.setSourceDLTLayerIndex(int32(converter.getSourceDLTLayerIndex(layer)));

    dltargets.internal.utils.LayerToCompUtils.setCustomHeaderProperty(comp,converter.layerHeaders);
end
