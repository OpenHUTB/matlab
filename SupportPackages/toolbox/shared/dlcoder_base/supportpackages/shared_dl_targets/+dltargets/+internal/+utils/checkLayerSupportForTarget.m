

function checkLayerSupportForTarget(layer,validator,unsupportedTargets)



    if any(strcmpi(validator.getTargetLib(),unsupportedTargets))
        layerType=class(layer);
        str=dltargets.internal.compbuilder.CodegenCompBuilder.getLayerName(layer,layerType);
        errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_layer',str,validator.getTargetLib());
        validator.handleError(layer,errorMessage);
    end
end
