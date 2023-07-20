function[algorithm,weightsReformatted,biasReformatted]=...
    convolutionDispatcher(layer,inputSize,buildContext)






















    if isa(layer.Weights,'embedded.fi')
        [algorithm,weightsReformatted]=iFixedPointDispatcher(layer,buildContext);
        biasReformatted=layer.Bias;
    else
        [algorithm,weightsReformatted,biasReformatted]=iDispatcher(layer,inputSize,buildContext);
    end

end

function[algorithm,weightsReformatted,biasReformatted]=iDispatcher(layer,inputSize,buildContext)

    biasReformatted=layer.Bias;



    if dlcoderfeature('UseCGIROptimizedLayerImplementation')&&...
        dltargets.internal.utils.isColumnMajorContext(buildContext)

        if dlcoderfeature('OneByOneConvAsCGIRMatMul')&&iIsConvEligibleForMatMul(layer)
            algorithm='OneByOneConvAsOptimizedMatMul';
        else
            algorithm='Optimized';
        end

        [weightsReformatted,biasReformatted]=...
        iReformatLearnablesForOptimizedImplementation(layer,inputSize,buildContext);

    elseif dltargets.internal.utils.isMexOrBlasCallbackEnabled(buildContext)




        if dltargets.internal.utils.isColumnMajorContext(buildContext)
            algorithm='GemmColMajor';
            weightsReformatted=...
            coder.internal.layer.convUtils.computeGemmWeightsColMajor(layer.Weights);
        else
            algorithm='GemmRowMajor';
            weightsReformatted=...
            coder.internal.layer.convUtils.computeGemmWeightsRowMajor(layer.Weights);
        end
    elseif coder.internal.layer.convUtils.isWinogradCompatible([size(layer.Weights,1)...
        ,size(layer.Weights,2)],layer.Stride,layer.Dilation)




        if dltargets.internal.utils.isColumnMajorContext(buildContext)
            algorithm='WinogradColMajor';
            weightsReformatted=...
            coder.internal.layer.convUtils.computeWinogradWeightsColMajor(layer.Weights);
        else
            algorithm='WinogradRowMajor';
            weightsReformatted=...
            coder.internal.layer.convUtils.computeWinogradWeightsRowMajor(layer.Weights);
        end
    else

        weightsReformatted=layer.Weights;
        if dltargets.internal.utils.isColumnMajorContext(buildContext)
            algorithm='DirectColMajor';
        else
            algorithm='DirectRowMajor';
        end
    end

end

function[algorithm,weightsReformatted]=iFixedPointDispatcher(layer,buildContext)



    weightsReformatted=layer.Weights;
    if dltargets.internal.utils.isColumnMajorContext(buildContext)
        algorithm='DirectColMajor';
    else
        algorithm='DirectRowMajor';
    end

end

function[weightsReformatted,biasReformatted]=...
    iReformatLearnablesForOptimizedImplementation(layer,inputSize,buildContext)

    if(dlcoderfeature('OneByOneConvAsCGIRMatMul')&&iIsConvEligibleForMatMul(layer))
        [weightsReformatted,biasReformatted]=coder.internal.layer.optimized.transform1x1ConvParamsTo2DMatrix(layer,inputSize);
    else
        specification=coder.internal.layer.convUtils.createOperationSpecification(layer,inputSize);

        convolutionParameters=coder.const(@feval,...
        'coder.internal.layer.parameterSelector.selectParameters',...
        'selectConvolutionParameters',specification,buildContext,...
        'coder.internal.layer.convUtils.CgirBaseParameters');

        [weightsReformatted,biasReformatted]=coder.const(@feval,...
        'coder.internal.layer.optimized.convReformatWeights',...
        layer.Weights,layer.Bias,convolutionParameters.InputChannelMiniblockSize,...
        convolutionParameters.SimdWidth);
    end


end

function convEligibleForMatmul=iIsConvEligibleForMatMul(layer)

    stride=layer.Stride;
    padding=layer.PaddingSize;
    dilation=layer.Dilation;








    convEligibleForMatmul=(size(layer.Weights,1)==1&&size(layer.Weights,2)==1)&&...
    (all(stride==1))&&...
    (all(dilation==1))&&...
    (all(padding==0));
end
