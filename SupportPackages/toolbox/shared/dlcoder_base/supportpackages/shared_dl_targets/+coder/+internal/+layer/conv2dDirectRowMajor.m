function Z=conv2dDirectRowMajor(layer,X,varargin)





























%#codegen


    coder.allowpcode('plain');


    narginchk(2,8);


    weights=layer.Weights;
    bias=layer.Bias;
    stride=layer.Stride;
    paddingSize=layer.PaddingSize;
    dilation=layer.Dilation;
    filterSize=layer.FilterSize;


    [args,hasActivation]=coder.internal.layer.utils.parseInferenceInputs(varargin{:},X);
    activationFunction=args.ActivationFunction;
    outPrototypeData=args.PrototypeData;


    [outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize]=coder.internal.layer.convUtils.computeOutputSize(X,...
    filterSize,layer.NumFilters,paddingSize,stride,dilation);



    if coder.const(hasActivation)





        Z=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],'single'));
    else

        Z=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],'like',outPrototypeData));
    end


    flattenedDimensionsConvolution=outputHeightSize*outputWidthSize*outputChannelSize*outputBatchSize;


    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();
    for idxFlattenedDimsConvolution=1:flattenedDimensionsConvolution


        [idxOutBatch,idxOutChannel,idxOutWidth,idxOutHeight]=ind2sub([outputBatchSize,outputChannelSize,outputWidthSize,outputHeightSize],idxFlattenedDimsConvolution);


        outPixel=coder.nullcopy(zeros(1,'like',outPrototypeData));
        outPixel(:)=bias(1,1,idxOutChannel);



        for idxFilterHeight=1:filterSize(1)
            for idxFilterWidth=1:filterSize(2)
                for idxFilterChannel=1:size(X,3)

                    idxInputHeight=(stride(1)*(idxOutHeight-1)+1)+...
                    (dilation(1)*(idxFilterHeight-1))-paddingSize(1);
                    idxInputWidth=(stride(2)*(idxOutWidth-1)+1)+...
                    (dilation(2)*(idxFilterWidth-1))-paddingSize(3);

                    if idxInputHeight>0&&idxInputWidth>0&&idxInputHeight<=size(X,1)&&idxInputWidth<=size(X,2)
                        inputPixel=X(idxInputHeight,idxInputWidth,idxFilterChannel,idxOutBatch);

                        outPixel(:)=outPixel+inputPixel*weights(idxFilterHeight,idxFilterWidth,idxFilterChannel,idxOutChannel);
                    end

                end
            end
        end


        Z(idxOutHeight,idxOutWidth,idxOutChannel,idxOutBatch)=activationFunction(outPixel);
    end

end
