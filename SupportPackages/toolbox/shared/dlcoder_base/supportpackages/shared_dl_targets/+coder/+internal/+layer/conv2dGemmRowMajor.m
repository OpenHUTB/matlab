function Z=conv2dGemmRowMajor(layer,X,varargin)

































%#codegen


    coder.allowpcode('plain');


    narginchk(2,8);


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

    weightMatrixHeight=size(weightMatrix,1);
    weightMatrixWidth=size(weightMatrix,2);

    imageMatrixHeight=outputHeightSize*outputWidthSize;
    imageMatrixWidth=weightMatrixHeight;


    Z=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],...
    'like',outPrototypeData));


    top=1;
    left=3;



    maxNumElemsPerBlock=(28*28)*(3*3*32);


    [numBlocks,numRowPerBlock,numRowPerBlockVec]=coder.internal.layer.convUtils.computeGemmConvBlockSizes(maxNumElemsPerBlock,imageMatrixWidth,imageMatrixHeight);

    imageMatrixBlock=coder.nullcopy(zeros(numRowPerBlock,imageMatrixWidth,'like',X));






    s.data=coder.nullcopy(zeros(numRowPerBlock,weightMatrixWidth,'like',X));
    convolutionMatrixByParts=repmat(s,numBlocks,1);


    intDilationHeightMinusOne=dilation(1)*filterHeight-1;
    intDilationWidthMinusOne=dilation(2)*filterWidth-1;

    paddingLowerWidth=1-paddingSize(left);
    paddingLowerHeight=1-paddingSize(top);

    filterHeightTimesWidth=coder.internal.indexInt(filterHeight*filterWidth);
    oneInt=coder.internal.indexInt(1);

    for idxImageBatch=1:outputBatchSize


        numElemsProcessed=coder.internal.indexInt(0);


        for idxBlock=1:numBlocks

            flattenedDimensionsIm2Row=numRowPerBlockVec(idxBlock)*numInputChannels;



            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();
            for idxFlattenedDimensionsIm2Row=1:flattenedDimensionsIm2Row



                idxFlattenedDimensionIm2RowTotal=coder.internal.indexInt(idxFlattenedDimensionsIm2Row)+numElemsProcessed;

                [idxChannel4DImage,idxTileCol4DImage,idxTileRow4DImage]=ind2sub([numInputChannels,outputWidthSize,outputHeightSize],idxFlattenedDimensionIm2RowTotal);

                [~,idxRowMatrixImage]=ind2sub([numInputChannels,numRowPerBlockVec(idxBlock)],idxFlattenedDimensionsIm2Row);

                idxColMatrixImage=(coder.internal.indexInt(idxChannel4DImage)-oneInt)*filterHeightTimesWidth+oneInt;


                lowerLimWidth=stride(2)*(idxTileCol4DImage-1)+paddingLowerWidth;
                upperLimWidth=lowerLimWidth+intDilationWidthMinusOne;
                lowerLimHeight=stride(1)*(idxTileRow4DImage-1)+paddingLowerHeight;
                upperLimHeight=lowerLimHeight+intDilationHeightMinusOne;







                if lowerLimWidth>0&&lowerLimHeight>0&&upperLimHeight<=size(X,1)&&upperLimWidth<=size(X,2)

                    for idxImageHeight=lowerLimHeight:dilation(1):upperLimHeight
                        for idxImageWidth=lowerLimWidth:dilation(2):upperLimWidth
                            imageMatrixBlock(idxRowMatrixImage,idxColMatrixImage)=X(idxImageHeight,idxImageWidth,idxChannel4DImage,idxImageBatch);
                            idxColMatrixImage=idxColMatrixImage+oneInt;
                        end
                    end
                else


                    for idxImageHeight=lowerLimHeight:dilation(1):upperLimHeight
                        for idxImageWidth=lowerLimWidth:dilation(2):upperLimWidth
                            if idxImageWidth>0&&idxImageHeight>0&&idxImageHeight<=size(X,1)&&idxImageWidth<=size(X,2)
                                imageMatrixBlock(idxRowMatrixImage,idxColMatrixImage)=X(idxImageHeight,idxImageWidth,idxChannel4DImage,idxImageBatch);
                            else
                                imageMatrixBlock(idxRowMatrixImage,idxColMatrixImage)=0;
                            end
                            idxColMatrixImage=idxColMatrixImage+oneInt;
                        end
                    end
                end

            end
            numElemsProcessed=numElemsProcessed+coder.internal.indexInt(flattenedDimensionsIm2Row);


            convolutionMatrixByParts(idxBlock).data=imageMatrixBlock*weightMatrix;
        end

        flattenedDimensionsRow2Im=outputChannelSize*outputHeightSize*outputWidthSize;


        coder.internal.treatAsParfor();
        coder.internal.parallelRelax();
        for idxFlattenedDimensionsRow2Im=1:flattenedDimensionsRow2Im


            [idxOutChannel,idxOutWidth,idxOutHeight]=ind2sub([outputChannelSize,outputWidthSize,outputHeightSize],idxFlattenedDimensionsRow2Im);


            [idxConvWidth,idxConvHeight,idxConvBlock]=ind2sub([weightMatrixWidth,numRowPerBlock,numBlocks],idxFlattenedDimensionsRow2Im);


            Z(idxOutHeight,idxOutWidth,idxOutChannel,idxImageBatch)=activationFunction(convolutionMatrixByParts(idxConvBlock).data(idxConvHeight,...
            idxConvWidth)+bias(1,1,idxOutChannel));

        end

    end

end
