
























function resultStruct=parseDLNetwork(dlnet)


    resultStruct=struct();


    [inputLayers,outputLayers]=dltargets.internal.getIOLayers(dlnet);







    [resultStruct.InputLayerIndices,resultStruct.OutputLayerIndices,resultStruct.NetworkInputSizes]=coder.internal.coderNetworkUtils.getSortedIOLayerIndices(dlnet,...
    inputLayers,...
    outputLayers);







    if~dlnet.Initialized
        error(message('gpucoder:validate:UninitializedDlnetworkNotSupported'));
    end


    resultStruct.HasSequenceInput=dltargets.internal.sharedNetwork.checkNetworkForSequenceInput(dlnet,inputLayers);

    resultStruct.InputNames=dlnet.InputNames;
    resultStruct.OutputNames=dlnet.OutputNames;

end
