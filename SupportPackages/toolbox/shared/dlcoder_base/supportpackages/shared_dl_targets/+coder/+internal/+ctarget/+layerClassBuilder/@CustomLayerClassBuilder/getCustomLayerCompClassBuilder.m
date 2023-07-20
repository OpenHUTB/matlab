







function[builder,builderFound]=getCustomLayerCompClassBuilder(layerComp,routineObject)


    assert(isa(layerComp,'gpucoder.layer_comp'),"Expected 1st input to be a pirComp.");

    isInputLayerComp=isa(layerComp,'gpucoder.input_layer_comp')||isa(layerComp,'gpucoder.sequence_input_layer_comp');

    if isInputLayerComp&&~layerComp.getExistsInLayerGraph()



        builder='PassThroughCustomLayerClassBuilder';
        builderFound=true;
    elseif isKey(coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.LayerCompToBuilderMap,layerComp.getCompKey())


        builder=coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.LayerCompToBuilderMap(layerComp.getCompKey());
        builderFound=true;
    else











        layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,routineObject.NetworkInfo);

        [builder,builderFound]=...
        coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.getCustomLayerClassBuilderName(layer,routineObject);

    end

end
