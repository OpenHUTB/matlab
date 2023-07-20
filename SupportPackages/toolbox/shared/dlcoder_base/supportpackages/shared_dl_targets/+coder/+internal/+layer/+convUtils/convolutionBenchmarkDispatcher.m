function[algorithm,weightsReformatted]=convolutionBenchmarkDispatcher(layer,inputSize,buildContext)























    if dlcoderfeature('ConvolutionDispatcherMode')==dlcoder_base.internal.EnumConvDispatcherMode.LayerName

        [algorithm,weightsReformatted]=iDispatchBasedOnLayerName(layer,inputSize,buildContext);
    else

        [algorithm,weightsReformatted]=iDispatchSameAlgorithmMode(layer);

    end

end


function[algorithm,weightsReformatted]=iDispatchBasedOnLayerName(layer,inputSize,buildContext)



    if contains(layer.Name,'GemmColMajor','IgnoreCase',true)

        algorithm='GemmColMajor';
        weightsReformatted=coder.internal.layer.convUtils.computeGemmWeightsColMajor(layer.Weights);
    elseif contains(layer.Name,'GemmRowMajor','IgnoreCase',true)

        algorithm='GemmRowMajor';
        weightsReformatted=coder.internal.layer.convUtils.computeGemmWeightsRowMajor(layer.Weights);


    elseif contains(layer.Name,'WinogradColMajor','IgnoreCase',true)


        if coder.internal.layer.convUtils.isWinogradCompatible([size(layer.Weights,1)...
            ,size(layer.Weights,2)],layer.Stride,layer.Dilation)

            algorithm='WinogradColMajor';
            weightsReformatted=...
            coder.internal.layer.convUtils.computeWinogradWeightsColMajor(layer.Weights);
        else

            errorMessage=message('dlcoder_spkg:cnncodegen:LayerIsNotWinogradCompatible',layer.Name);
            error(errorMessage);
        end
    elseif contains(layer.Name,'WinogradRowMajor','IgnoreCase',true)


        if coder.internal.layer.convUtils.isWinogradCompatible([size(layer.Weights,1)...
            ,size(layer.Weights,2)],layer.Stride,layer.Dilation)

            algorithm='WinogradRowMajor';
            weightsReformatted=...
            coder.internal.layer.convUtils.computeWinogradWeightsRowMajor(layer.Weights);
        else

            errorMessage=message('dlcoder_spkg:cnncodegen:LayerIsNotWinogradCompatible',layer.Name);
            error(errorMessage);
        end


    elseif contains(layer.Name,'DirectColMajor','IgnoreCase',true)

        algorithm='DirectColMajor';
        weightsReformatted=layer.Weights;
    elseif contains(layer.Name,'DirectRowMajor','IgnoreCase',true)

        algorithm='DirectRowMajor';
        weightsReformatted=layer.Weights;
    else

        [algorithm,weightsReformatted]=coder.internal.layer.convUtils.convolutionDispatcher(...
        layer,inputSize,buildContext);
    end
end


function[algorithm,weightsReformatted]=iDispatchSameAlgorithmMode(layer)


    switch dlcoderfeature('ConvolutionDispatcherMode')

    case dlcoder_base.internal.EnumConvDispatcherMode.GemmColMajor

        algorithm='GemmColMajor';
        weightsReformatted=coder.internal.layer.convUtils.computeGemmWeightsColMajor(layer.Weights);

    case dlcoder_base.internal.EnumConvDispatcherMode.GemmRowMajor

        algorithm='GemmRowMajor';
        weightsReformatted=coder.internal.layer.convUtils.computeGemmWeightsRowMajor(layer.Weights);

    case dlcoder_base.internal.EnumConvDispatcherMode.WinogradColMajor

        if coder.internal.layer.convUtils.isWinogradCompatible([size(layer.Weights,1)...
            ,size(layer.Weights,2)],layer.Stride,layer.Dilation)

            algorithm='WinogradColMajor';
            weightsReformatted=...
            coder.internal.layer.convUtils.computeWinogradWeightsColMajor(layer.Weights);
        else

            errorMessage=message('dlcoder_spkg:cnncodegen:LayerIsNotWinogradCompatible',layer.Name);
            error(errorMessage);
        end

    case dlcoder_base.internal.EnumConvDispatcherMode.WinogradRowMajor

        if coder.internal.layer.convUtils.isWinogradCompatible([size(layer.Weights,1)...
            ,size(layer.Weights,2)],layer.Stride,layer.Dilation)

            algorithm='WinogradRowMajor';
            weightsReformatted=...
            coder.internal.layer.convUtils.computeWinogradWeightsRowMajor(layer.Weights);
        else

            errorMessage=message('dlcoder_spkg:cnncodegen:LayerIsNotWinogradCompatible',layer.Name);
            error(errorMessage);
        end

    case dlcoder_base.internal.EnumConvDispatcherMode.DirectColMajor

        algorithm='DirectColMajor';
        weightsReformatted=layer.Weights;

    case dlcoder_base.internal.EnumConvDispatcherMode.DirectRowMajor

        algorithm='DirectRowMajor';
        weightsReformatted=layer.Weights;
    end

end
