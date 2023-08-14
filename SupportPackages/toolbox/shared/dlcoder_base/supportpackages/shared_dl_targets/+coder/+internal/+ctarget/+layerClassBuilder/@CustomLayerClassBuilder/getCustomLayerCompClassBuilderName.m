

function[builderName,builderFound]=getCustomLayerCompClassBuilderName(layerComp,routineObject)





    prefix='coder.internal.ctarget.layerClassBuilder.';

    [builderName,builderFound]=...
    coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.getCustomLayerCompClassBuilder(...
    layerComp,routineObject);

    if~contains(builderName,prefix)
        builderName=[prefix,builderName];
    end

end
