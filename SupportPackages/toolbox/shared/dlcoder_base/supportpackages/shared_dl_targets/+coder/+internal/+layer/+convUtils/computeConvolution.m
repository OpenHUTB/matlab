function Z=computeConvolution(layer,X,convolutionFunction,varargin)






%#codegen



    coder.inline('always')
    coder.allowpcode('plain')


    [args,hasActivation]=coder.internal.layer.utils.parseInferenceInputs(varargin{:},X);
    activationFunction=args.ActivationFunction;
    activationFunctionType=coder.const(args.ActivationFunctionType);
    activationParams=coder.const(args.ActivationParams);

    if~coder.internal.isConst(size(X,4))&&coder.const(@strcmp,layer.Algorithm,'Optimized')

        [outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize]=...
        coder.internal.layer.convUtils.computeOutputSize(X,layer.FilterSize,layer.NumFilters,layer.PaddingSize,...
        layer.Stride,layer.Dilation);
        Z=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],'like',X));
        for foldedDimIdx=1:size(X,4)


            if coder.const(hasActivation)
                Z(:,:,:,foldedDimIdx)=convolutionFunction(layer,X(:,:,:,foldedDimIdx),...
                'ActivationFunction',activationFunction,...
                'ActivationFunctionType',activationFunctionType,...
                'ActivationParams',activationParams);
            else
                Z(:,:,:,foldedDimIdx)=convolutionFunction(layer,X(:,:,:,foldedDimIdx));
            end
        end
    else

        if coder.const(hasActivation)
            Z=convolutionFunction(layer,X,...
            'ActivationFunction',activationFunction,...
            'ActivationFunctionType',activationFunctionType,...
            'ActivationParams',activationParams);
        else
            Z=convolutionFunction(layer,X);
        end
    end

end