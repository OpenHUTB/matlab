function Z=conv2dGemmColMajor(layer,X,varargin)
































%#codegen


    coder.allowpcode('plain');


    narginchk(2,4);


    weightMatrix=layer.Weights;
    bias=layer.Bias;
    stride=layer.Stride;
    paddingSize=layer.PaddingSize;
    dilation=layer.Dilation;
    filterSize=layer.FilterSize;
    outputChannelSize=layer.NumFilters;


    args=coder.internal.layer.utils.parseInferenceInputs(varargin{:},X);
    activationFunction=args.ActivationFunction;
    outPrototypeData=args.PrototypeData;


    numInputChannels=coder.const(size(X,3));


    [outputHeightSize,outputWidthSize,~,outputBatchSize]=coder.internal.layer.convUtils.computeOutputSize(X,...
    filterSize,layer.NumFilters,paddingSize,stride,dilation);


    filterHeight=filterSize(1);
    filterWidth=filterSize(2);
    filterChannel=layer.NumChannels;


    weightMatrixHeight=size(weightMatrix,1);
    weightMatrixWidth=filterHeight*filterWidth*filterChannel;


    imageMatrixHeight=weightMatrixWidth;
    imageMatrixWidth=outputHeightSize*outputWidthSize;


    Z=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],...
    'like',outPrototypeData));


    top=1;
    left=3;



    maxNumElemsPerBlock=(28*28)*(3*3*32);


    [numBlocks,numColumnPerBlock,numColumnPerBlockVec]=coder.internal.layer.convUtils.computeGemmConvBlockSizes(maxNumElemsPerBlock,imageMatrixHeight,imageMatrixWidth);

    convolutionMatrixByParts=coder.nullcopy(zeros(weightMatrixHeight,numColumnPerBlock,numBlocks,'like',X));

    imageMatrixBlock=coder.nullcopy(zeros(imageMatrixHeight,numColumnPerBlock,'like',X));


    intDilationHeightMinusOne=dilation(1)*filterHeight-1;
    intDilationWidthMinusOne=dilation(2)*filterWidth-1;

    paddingLowerWidth=1-paddingSize(left);
    paddingLowerHeight=1-paddingSize(top);

    filterHeightTimesWidth=coder.internal.indexInt(filterWidth*filterHeight);
    oneInt=coder.internal.indexInt(1);


    for idxImageBatch=1:outputBatchSize


        numElemsProcessed=coder.internal.indexInt(0);


        for idxBlock=1:numBlocks

            flattenedDimensionsIm2Col=numColumnPerBlockVec(idxBlock)*numInputChannels;



            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for idxFlattenedDimensionsIm2Col=1:flattenedDimensionsIm2Col



                idxFlattenedDimensionIm2ColTotal=coder.internal.indexInt(idxFlattenedDimensionsIm2Col)+numElemsProcessed;

                [idxChannel4DImage,idxTileCol4DImage,idxTileRow4DImage]=ind2sub([numInputChannels,outputWidthSize,outputHeightSize],idxFlattenedDimensionIm2ColTotal);

                [~,idxColMatrixImage]=ind2sub([numInputChannels,numColumnPerBlockVec(idxBlock)],idxFlattenedDimensionsIm2Col);

                idxRowMatrixImage=(coder.internal.indexInt(idxChannel4DImage)-oneInt)*filterHeightTimesWidth+oneInt;


                lowerLimWidth=stride(2)*(idxTileCol4DImage-1)+paddingLowerWidth;
                upperLimWidth=lowerLimWidth+intDilationWidthMinusOne;
                lowerLimHeight=stride(1)*(idxTileRow4DImage-1)+paddingLowerHeight;
                upperLimHeight=lowerLimHeight+intDilationHeightMinusOne;







                if lowerLimWidth>0&&lowerLimHeight>0&&upperLimHeight<=size(X,1)&&upperLimWidth<=size(X,2)

                    for idxImageWidth=lowerLimWidth:dilation(2):upperLimWidth
                        for idxImageHeight=lowerLimHeight:dilation(1):upperLimHeight
                            imageMatrixBlock(idxRowMatrixImage,idxColMatrixImage)=X(idxImageHeight,idxImageWidth,idxChannel4DImage,idxImageBatch);
                            idxRowMatrixImage=idxRowMatrixImage+oneInt;
                        end
                    end
                else


                    for idxImageWidth=lowerLimWidth:dilation(2):upperLimWidth
                        for idxImageHeight=lowerLimHeight:dilation(1):upperLimHeight
                            if idxImageWidth>0&&idxImageHeight>0&&idxImageHeight<=size(X,1)&&idxImageWidth<=size(X,2)
                                imageMatrixBlock(idxRowMatrixImage,idxColMatrixImage)=X(idxImageHeight,idxImageWidth,idxChannel4DImage,idxImageBatch);
                            else
                                imageMatrixBlock(idxRowMatrixImage,idxColMatrixImage)=0;
                            end
                            idxRowMatrixImage=idxRowMatrixImage+oneInt;
                        end
                    end
                end

            end
            numElemsProcessed=numElemsProcessed+coder.internal.indexInt(flattenedDimensionsIm2Col);


            convolutionMatrixByParts(:,:,idxBlock)=weightMatrix*imageMatrixBlock;
        end
        flattenedDimensionsCol2Im=outputChannelSize*outputHeightSize*outputWidthSize;


        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for idxFlattenedDimensionsCol2Im=1:flattenedDimensionsCol2Im


            [idxOutChannel,idxOutWidth,idxOutHeight]=ind2sub([outputChannelSize,outputWidthSize,outputHeightSize],idxFlattenedDimensionsCol2Im);


            [idxConvHeight,idxConvWidth,idxConvBlock]=ind2sub([weightMatrixHeight,numColumnPerBlock,...
            numBlocks],idxFlattenedDimensionsCol2Im);


            Z(idxOutHeight,idxOutWidth,idxOutChannel,idxImageBatch)=activationFunction(convolutionMatrixByParts(idxConvHeight,...
            idxConvWidth,idxConvBlock)+bias(1,1,idxOutChannel));

        end

    end

end
