function Z=conv2dWinogradRowMajor(layer,X,varargin)






























%#codegen


    coder.allowpcode('plain');


    narginchk(2,8);


    U=layer.Weights;
    bias=layer.Bias;
    stride=layer.Stride;
    paddingSize=layer.PaddingSize;
    dilation=layer.Dilation;


    args=coder.internal.layer.utils.parseInferenceInputs(varargin{:},X);
    activationFunction=args.ActivationFunction;
    outPrototypeData=args.PrototypeData;


    [H,W,C,N]=size(X,1:4);

    weightsOriginalSize=[3,3,coder.const(size(U,4)),coder.const(size(U,3))];
    K=weightsOriginalSize(4);

    [outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize]=coder.internal.layer.convUtils.computeOutputSize(X,...
    weightsOriginalSize(1:2),weightsOriginalSize(4),paddingSize,stride,dilation);
    Z=coder.nullcopy(zeros([outputHeightSize,outputWidthSize,outputChannelSize,outputBatchSize],'like',outPrototypeData));


    top=1;bottom=2;left=3;right=4;
    paddedH=H+paddingSize(top)+paddingSize(bottom);
    paddedW=W+paddingSize(left)+paddingSize(right);
    oddH=mod(paddedH,2);
    oddW=mod(paddedW,2);

    H=paddedH+oddH;
    W=paddedW+oddW;

    numberOfTilesHeight=ceil(H/2)-1;
    numberOfTilesWidth=ceil(W/2)-1;
    P=numberOfTilesHeight*numberOfTilesWidth*N;


    V=coder.nullcopy(zeros(4,4,C,P,'like',U));




    paddingLowerWidth=-1-paddingSize(left);
    paddingLowerHeight=-1-paddingSize(top);
    oneInt=coder.internal.indexInt(1);



    flattenedDimensionsPatchExtraction=C*N*numberOfTilesHeight*numberOfTilesWidth;
    productNumTilesHWN=coder.internal.indexInt(numberOfTilesHeight*numberOfTilesWidth*N);

    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();
    for idxFlattenedDimsPatchExtraction=1:flattenedDimensionsPatchExtraction


        [idxTileHeight,idxTileWidth,idxBatch,idxChannel]=ind2sub([numberOfTilesWidth,numberOfTilesHeight,N,C],idxFlattenedDimsPatchExtraction);


        idxTileNo=mod(coder.internal.indexInt(idxFlattenedDimsPatchExtraction)-oneInt,productNumTilesHWN)+oneInt;



        lowerLimWidth=2*idxTileHeight+paddingLowerWidth;
        upperLimWidth=lowerLimWidth+3;
        lowerLimHeight=2*idxTileWidth+paddingLowerHeight;
        upperLimHeight=lowerLimHeight+3;

        imagePatch=coder.nullcopy(zeros(4,4,'like',X));




        if lowerLimWidth>0&&lowerLimHeight>0&&upperLimHeight<=size(X,1)&&upperLimWidth<=size(X,2)

            for heightIdx=1:4
                for widthIdx=1:4
                    imagePatch(heightIdx,widthIdx)=X(lowerLimHeight+heightIdx-1,lowerLimWidth+widthIdx-1,idxChannel,idxBatch);
                end
            end

        else

            for heightIdx=1:4
                for widthIdx=1:4
                    pixelLocationHeight=lowerLimHeight+heightIdx-1;
                    pixelLocationWidth=lowerLimWidth+widthIdx-1;
                    if(pixelLocationHeight<=0||pixelLocationHeight>size(X,1))||(pixelLocationWidth<=0||pixelLocationWidth>size(X,2))
                        imagePatch(heightIdx,widthIdx)=0;
                    else
                        imagePatch(heightIdx,widthIdx)=X(pixelLocationHeight,pixelLocationWidth,idxChannel,idxBatch);
                    end

                end
            end
        end



        V(1,1,idxChannel,idxTileNo)=imagePatch(1,1)-imagePatch(1,3)-imagePatch(3,1)+imagePatch(3,3);
        V(1,2,idxChannel,idxTileNo)=imagePatch(1,2)+imagePatch(1,3)-imagePatch(3,2)-imagePatch(3,3);
        V(1,3,idxChannel,idxTileNo)=imagePatch(1,3)-imagePatch(1,2)+imagePatch(3,2)-imagePatch(3,3);
        V(1,4,idxChannel,idxTileNo)=imagePatch(1,2)-imagePatch(1,4)-imagePatch(3,2)+imagePatch(3,4);

        V(2,1,idxChannel,idxTileNo)=imagePatch(2,1)-imagePatch(2,3)+imagePatch(3,1)-imagePatch(3,3);
        V(2,2,idxChannel,idxTileNo)=imagePatch(2,2)+imagePatch(2,3)+imagePatch(3,2)+imagePatch(3,3);
        V(2,3,idxChannel,idxTileNo)=imagePatch(2,3)-imagePatch(2,2)-imagePatch(3,2)+imagePatch(3,3);
        V(2,4,idxChannel,idxTileNo)=imagePatch(2,2)-imagePatch(2,4)+imagePatch(3,2)-imagePatch(3,4);

        V(3,1,idxChannel,idxTileNo)=imagePatch(2,3)-imagePatch(2,1)+imagePatch(3,1)-imagePatch(3,3);
        V(3,2,idxChannel,idxTileNo)=imagePatch(3,2)-imagePatch(2,3)-imagePatch(2,2)+imagePatch(3,3);
        V(3,3,idxChannel,idxTileNo)=imagePatch(2,2)-imagePatch(2,3)-imagePatch(3,2)+imagePatch(3,3);
        V(3,4,idxChannel,idxTileNo)=imagePatch(2,4)-imagePatch(2,2)+imagePatch(3,2)-imagePatch(3,4);

        V(4,1,idxChannel,idxTileNo)=imagePatch(2,1)-imagePatch(2,3)-imagePatch(4,1)+imagePatch(4,3);
        V(4,2,idxChannel,idxTileNo)=imagePatch(2,2)+imagePatch(2,3)-imagePatch(4,2)-imagePatch(4,3);
        V(4,3,idxChannel,idxTileNo)=imagePatch(2,3)-imagePatch(2,2)+imagePatch(4,2)-imagePatch(4,3);
        V(4,4,idxChannel,idxTileNo)=imagePatch(2,2)-imagePatch(2,4)-imagePatch(4,2)+imagePatch(4,4);

    end










    s.data=coder.nullcopy(zeros(K,P,'like',U));

    M=repmat(s,4,4);
    flattenedDimensions4x4Patch=16;

    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();
    for idxFlattenedDims4x4Patch=1:flattenedDimensions4x4Patch

        [j,i]=ind2sub([4,4],idxFlattenedDims4x4Patch);




        if coder.const(size(U,3)==1||size(V,3)==1)


            M(i,j).data=reshape(U(i,j,:,:),size(U,[3,4]))*reshape(V(i,j,:,:),size(V,[3,4]));
        else


            M(i,j).data=squeeze(U(i,j,:,:))*squeeze(V(i,j,:,:));
        end
    end



    flattenedDimensionsForOutput=numberOfTilesHeight*numberOfTilesWidth*N*K;

    productNumTilesHWN=coder.internal.indexInt(numberOfTilesHeight*numberOfTilesWidth*N);


    outputPatch=coder.nullcopy(zeros(2,2,'like',X));



    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();
    for idxFlattenedDimsForOutput=1:flattenedDimensionsForOutput


        [idxTileWidth,idxTileHeight,idxBatch,idxChannel]=ind2sub([numberOfTilesWidth,numberOfTilesHeight,N,K],idxFlattenedDimsForOutput);

        idxTileNo=mod((coder.internal.indexInt(idxFlattenedDimsForOutput)-oneInt),productNumTilesHWN)+oneInt;


        outputPatch(1,1)=M(1,1).data(idxChannel,idxTileNo)+M(1,2).data(idxChannel,idxTileNo)+M(1,3).data(idxChannel,idxTileNo)+M(2,1).data(idxChannel,idxTileNo)+M(2,2).data(idxChannel,idxTileNo)+M(2,3).data(idxChannel,idxTileNo)+M(3,1).data(idxChannel,idxTileNo)+M(3,2).data(idxChannel,idxTileNo)+M(3,3).data(idxChannel,idxTileNo)+bias(1,1,idxChannel);
        outputPatch(1,2)=M(1,2).data(idxChannel,idxTileNo)-M(1,3).data(idxChannel,idxTileNo)-M(1,4).data(idxChannel,idxTileNo)+M(2,2).data(idxChannel,idxTileNo)-M(2,3).data(idxChannel,idxTileNo)-M(2,4).data(idxChannel,idxTileNo)+M(3,2).data(idxChannel,idxTileNo)-M(3,3).data(idxChannel,idxTileNo)-M(3,4).data(idxChannel,idxTileNo)+bias(1,1,idxChannel);
        outputPatch(2,1)=M(2,1).data(idxChannel,idxTileNo)+M(2,2).data(idxChannel,idxTileNo)+M(2,3).data(idxChannel,idxTileNo)-M(3,1).data(idxChannel,idxTileNo)-M(3,2).data(idxChannel,idxTileNo)-M(3,3).data(idxChannel,idxTileNo)-M(4,1).data(idxChannel,idxTileNo)-M(4,2).data(idxChannel,idxTileNo)-M(4,3).data(idxChannel,idxTileNo)+bias(1,1,idxChannel);
        outputPatch(2,2)=M(2,2).data(idxChannel,idxTileNo)-M(2,3).data(idxChannel,idxTileNo)-M(2,4).data(idxChannel,idxTileNo)-M(3,2).data(idxChannel,idxTileNo)+M(3,3).data(idxChannel,idxTileNo)+M(3,4).data(idxChannel,idxTileNo)-M(4,2).data(idxChannel,idxTileNo)+M(4,3).data(idxChannel,idxTileNo)+M(4,4).data(idxChannel,idxTileNo)+bias(1,1,idxChannel);

        if(idxTileHeight<=numberOfTilesHeight-oddH)
            if(idxTileWidth<=numberOfTilesWidth-oddW)
                for idxRow=1:2
                    for idxCol=1:2
                        Z(2*idxTileHeight-2+idxRow,2*idxTileWidth-2+idxCol,idxChannel,idxBatch)=activationFunction(outputPatch(idxRow,idxCol));
                    end
                end
            else



                for idxRow=1:2
                    Z(2*idxTileHeight-2+idxRow,2*idxTileWidth-1,idxChannel,idxBatch)=activationFunction(outputPatch(idxRow,1));
                end
            end

        else



            if(idxTileWidth<=numberOfTilesWidth-oddW)
                for idxCol=1:2
                    Z(2*idxTileHeight-1,2*idxTileWidth-2+idxCol,idxChannel,idxBatch)=activationFunction(outputPatch(1,idxCol));
                end
            else


                Z(2*idxTileHeight-1,2*idxTileWidth-1,idxChannel,idxBatch)=activationFunction(outputPatch(1,1));
            end

        end

    end

end
