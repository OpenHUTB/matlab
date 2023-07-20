






function[builder,builderFound]=getCompBuilder(layer,routineObject)



    if isKey(dltargets.internal.compbuilder.CodegenCompBuilder.layerToBuilderMap,class(layer))
        builder=dltargets.internal.compbuilder.CodegenCompBuilder.layerToBuilderMap(class(layer));





        if(isa(routineObject,'dltargets.internal.compbuilder.CodegenLayerConverter')||...
            isa(routineObject,'dltargets.internal.compbuilder.CodegenLayerFileSaver'))&&...
            ~routineObject.NetworkInfo.IsDLNetwork&&...
            dltargets.internal.isFCConvertedToConv(layer,routineObject.NetworkInfo)
            builder='ConvCompBuilder';
        end
        builderFound=true;

    elseif dltargets.internal.checkIfOutputLayer(layer)
        builder='OutputCompBuilder';
        builderFound=true;

    elseif dltargets.internal.checkIfCustomLayer(layer)
        builder='DLTCustomCompBuilder';
        builderFound=true;
    else
        builder='';
        builderFound=false;
    end
end
