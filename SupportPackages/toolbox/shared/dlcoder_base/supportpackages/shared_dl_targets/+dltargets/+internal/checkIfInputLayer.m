function isInputLayer=checkIfInputLayer(layer)






    ilayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
    isInputLayer=isa(ilayer{1},'nnet.internal.cnn.layer.InputLayer');

    if isInputLayer&&coder.internal.hasPublicStaticMethod(class(layer),'matlabCodegenRedirect')



        isInputLayer=false;
    end


end