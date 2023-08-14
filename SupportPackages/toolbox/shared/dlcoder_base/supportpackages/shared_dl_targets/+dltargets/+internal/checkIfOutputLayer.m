function isOutputLayer=checkIfOutputLayer(layer)




    ilayer=nnet.cnn.layer.Layer.getInternalLayers(layer);

    isOutputLayer=isa(ilayer{1},'nnet.internal.cnn.layer.OutputLayer');

end