function convLayer=modifyConvolutionLearnableParams(convLayer,BNLayer)






























    internalConvLayer=nnet.internal.cnn.layer.util.ExternalInternalConverter.getInternalLayers(convLayer);
    internalConvLayer=internalConvLayer{1};

    internalBNLayer=nnet.internal.cnn.layer.util.ExternalInternalConverter.getInternalLayers(BNLayer);
    internalBNLayer=internalBNLayer{1};

    [adjustedWeights,adjustedBias]=nnet.internal.cnn.layer.util.adjustLearnablesForConvBatchNormFusion(internalConvLayer,internalBNLayer);


    internalConvLayer.Weights.Value=adjustedWeights;
    internalConvLayer.Bias.Value=adjustedBias;

    if(isa(convLayer,'nnet.cnn.layer.GroupedConvolution2DLayer'))
        convLayer=nnet.cnn.layer.GroupedConvolution2DLayer(internalConvLayer);
    else
        convLayer=nnet.cnn.layer.Convolution2DLayer(internalConvLayer);
    end

end