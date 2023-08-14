

function createFunctionStruct=populateCreateFunctionStruct(layerString,target)





    createFunctionStruct.layerString=layerString;
    createFunctionStruct.target=target;

    createFunctionStruct.layer='MWCNNLayer';
    createFunctionStruct.layerImplBase='MWCNNLayerImplBase';
    createFunctionStruct.targetNetworkImpl='MWTargetNetworkImpl';
    createFunctionStruct.targetNetworkImplBase=[createFunctionStruct.targetNetworkImpl,'Base'];

    createFunctionStruct.layerImplFactory=['MW',target,'LayerImplFactory'];
    createFunctionStruct.targetNamespace=['MW',target,'Target'];
    createFunctionStruct.layerImpl=['MW',layerString,'LayerImpl'];
    createFunctionStruct.createFunction=['create',layerString,'LayerImpl'];

    if dltargets.internal.layerImplFactoryEmitter.isTemplatizedLayer(layerString)
        argTypes=dltargets.internal.layerImplFactoryEmitter.getTemplatizedCreateLayerImplArgTypes(layerString,target);
        templateActualTypes=dltargets.internal.layerImplFactoryEmitter.getTemplatizedLayerActualTypes(layerString);
    else
        argTypes=dltargets.internal.layerImplFactoryEmitter.getCreateLayerImplArgTypes(layerString);
        templateActualTypes={};
    end

    createFunctionStruct.createArgTypes=argTypes;
    createFunctionStruct.templateActuals=templateActualTypes;
end
