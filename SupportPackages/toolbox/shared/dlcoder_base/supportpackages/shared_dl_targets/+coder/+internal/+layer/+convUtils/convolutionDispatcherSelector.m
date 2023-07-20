function[algorithm,weightsReformatted,biasReformatted,selectedDispatcher]=...
    convolutionDispatcherSelector(layer,inputSize,buildContext)

























    if dlcoderfeature('ConvolutionDispatcherMode')==dlcoder_base.internal.EnumConvDispatcherMode.Performance


        [algorithm,weightsReformatted,biasReformatted]=...
        coder.internal.layer.convUtils.convolutionDispatcher(layer,inputSize,buildContext);
        selectedDispatcher='convolutionDispatcher';
    else


        [algorithm,weightsReformatted]=...
        coder.internal.layer.convUtils.convolutionBenchmarkDispatcher(layer,inputSize,buildContext);
        selectedDispatcher='convolutionBenchmarkDispatcher';
        biasReformatted=layer.Bias;
    end

end
