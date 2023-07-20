




















function resultStruct=parseNetwork(net)





    resultStruct=struct();


    [InputLayers,OutputLayers]=dltargets.internal.getIOLayers(net);


    [resultStruct.InputLayerIndices,resultStruct.OutputLayerIndices,resultStruct.NetworkInputSizes]=coder.internal.coderNetworkUtils.getSortedIOLayerIndices(net,...
    InputLayers,...
    OutputLayers);



    resultStruct.IsRNN=any(cellfun(@(layer)isa(layer,'nnet.cnn.layer.SequenceInputLayer'),InputLayers));


    resultStruct.HasSequenceOutput=net.getInternalDAGNetwork.HasSequenceOutput;


    classificationLayerArray=iCheckForClassificationLayers(OutputLayers);
    resultStruct.ClassificationLayers=classificationLayerArray;

    resultStruct.InputNames=net.InputNames;
    resultStruct.OutputNames=net.OutputNames;

end

function classLayerArray=iCheckForClassificationLayers(outputLayers)

    classLayerArray=cellfun(@(layer)iIsClassificationOutputLayer(layer),outputLayers);

end

function isClassificationOutputLayer=iIsClassificationOutputLayer(layer)
    isClassificationOutputLayer=dltargets.internal.utils.LayerAnalysis.isClassificationOutputLayer(layer);
end

