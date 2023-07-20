




function[builder,builderFound]=getCustomLayerClassBuilder(layer,routineObject)




    if isKey(coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.LayerToBuilderMap,class(layer))
        builder=coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.LayerToBuilderMap(class(layer));






        if isa(routineObject,'coder.internal.ctarget.layerClassBuilder.CustomLayerClassConverter')&&...
            ~routineObject.NetworkInfo.IsDLNetwork&&dltargets.internal.isFCConvertedToConv(layer,routineObject.NetworkInfo)
            builder='ConvCustomLayerClassBuilder';
        end

        builderFound=true;

    elseif dlcoderfeature('EnableCustomLayerPrototypes')&&...
        isKey(coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.PrototypedLayerToBuilderMap,class(layer))
        builder=coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.PrototypedLayerToBuilderMap(class(layer));
        builderFound=true;

    elseif dltargets.internal.checkIfOutputLayer(layer)
        builder='PassThroughCustomLayerClassBuilder';
        builderFound=true;

    elseif dltargets.internal.checkIfCustomLayer(layer)
        builder='DLTCustomLayerClassBuilder';
        builderFound=true;

    else
        builder='';
        builderFound=false;
    end
end
