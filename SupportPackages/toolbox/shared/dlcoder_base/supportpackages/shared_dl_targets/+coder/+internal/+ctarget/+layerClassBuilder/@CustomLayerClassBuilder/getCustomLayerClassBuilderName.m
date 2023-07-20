

function[builderName,builderFound]=getCustomLayerClassBuilderName(layer,routineObject)





    prefix='coder.internal.ctarget.layerClassBuilder.';

    [compBuilderString,builderFound]=...
    coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.getCustomLayerClassBuilder(layer,routineObject);

    builderName=[prefix,compBuilderString];
end
