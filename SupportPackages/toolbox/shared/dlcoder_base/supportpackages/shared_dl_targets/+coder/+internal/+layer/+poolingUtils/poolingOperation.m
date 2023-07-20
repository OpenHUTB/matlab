function Z=poolingOperation(layer,X,poolingWindowFunc,poolingAssignFunc,paddingValue,initOpValue)





















%#codegen

    coder.allowpcode('plain');

    coder.internal.prefer_const(paddingValue,initOpValue);
    [hOut,wOut,cOut,bOut]=iComputeOutputSize(layer,X);
    Z=coder.nullcopy(zeros([hOut,wOut,cOut,bOut],'like',X));


    if coder.isColumnMajor


        if coder.const(coder.internal.coderNetworkUtils.canUseMultiThreading())
            Z=iPoolingForColumnMajorWithOpenMP(layer,X,Z,poolingWindowFunc,poolingAssignFunc,...
            paddingValue,initOpValue);
        else
            Z=iPoolingForColumnMajorWithoutOpenMP(layer,X,Z,poolingWindowFunc,poolingAssignFunc,...
            paddingValue,initOpValue);
        end

    else


        if coder.const(coder.internal.coderNetworkUtils.canUseMultiThreading())

            Z=iPoolingForRowMajorWithOpenMP(layer,X,Z,poolingWindowFunc,poolingAssignFunc,...
            paddingValue,initOpValue);
        else

            Z=iPoolingForRowMajorWithoutOpenMP(layer,X,Z,poolingWindowFunc,poolingAssignFunc,...
            paddingValue,initOpValue);
        end
    end

end

function Z=iPoolingForColumnMajorWithOpenMP(layer,X,Z,poolingWindowFunc,poolingAssignFunc,...
    paddingValue,initOpValue)

    coder.internal.prefer_const(paddingValue,initOpValue);


    [strideVert,strideHorz,poolSzHeight,poolSzWidth,...
    paddingSzTop,paddingSzLeft]=iExtractPoolingLayerParams(layer);

    outputSize=size(Z);
    prodOutDims=numel(Z);


    parfor prodOutDimsIdx=1:prodOutDims


        [outHeightIdx,outWidthIdx,outChannelIdx,outBatchIdx]=ind2sub(outputSize,prodOutDimsIdx);

        inputHeightIdx=1+strideVert*(outHeightIdx-1)-paddingSzTop;
        inputWidthIdx=1+strideHorz*(outWidthIdx-1)-paddingSzLeft;


        opValue=initOpValue;




        if inputHeightIdx>0&&inputWidthIdx>0&&(inputHeightIdx+poolSzHeight)<=size(X,1)&&(inputWidthIdx+poolSzWidth)<=size(X,2)



            for filterWidthIdx=1:poolSzWidth
                inputWidthIdx=filterWidthIdx+strideHorz*(outWidthIdx-1)-paddingSzLeft;
                for filterHeightIdx=1:poolSzHeight

                    inputHeightIdx=filterHeightIdx+strideVert*(outHeightIdx-1)-paddingSzTop;
                    inputPixel=X(inputHeightIdx,inputWidthIdx,outChannelIdx,outBatchIdx);


                    opValue=poolingWindowFunc(opValue,inputPixel);%#ok
                end
            end

        else


            for filterWidthIdx=1:poolSzWidth
                inputWidthIdx=filterWidthIdx+strideHorz*(outWidthIdx-1)-paddingSzLeft;
                for filterHeightIdx=1:poolSzHeight
                    inputHeightIdx=filterHeightIdx+strideVert*(outHeightIdx-1)-paddingSzTop;


                    if inputHeightIdx>0&&inputWidthIdx>0&&inputHeightIdx<=size(X,1)&&inputWidthIdx<=size(X,2)
                        inputPixel=X(inputHeightIdx,inputWidthIdx,outChannelIdx,outBatchIdx);
                    else
                        inputPixel=paddingValue;
                    end


                    opValue=poolingWindowFunc(opValue,inputPixel);

                end
            end
        end


        Z(prodOutDimsIdx)=poolingAssignFunc(opValue);%#ok

    end
end


function Z1=iPoolingForColumnMajorWithoutOpenMP(layer,X1,Z1,poolingWindowFunc,poolingAssignFunc,...
    paddingValue,initOpValue)

    coder.internal.prefer_const(paddingValue,initOpValue);


    [strideVert,strideHorz,poolSzHeight,poolSzWidth,...
    paddingSzTop,paddingSzLeft]=iExtractPoolingLayerParams(layer);

    for outBatchIdx=1:size(Z1,4)
        for outChannelIdx=1:size(Z1,3)
            for outWidthIdx=1:size(Z1,2)
                for outHeightIdx=1:size(Z1,1)

                    inputWidthIdx=1+strideHorz*(outWidthIdx-1)-paddingSzLeft;
                    inputHeightIdx=1+strideVert*(outHeightIdx-1)-paddingSzTop;


                    opValue=initOpValue;




                    if inputHeightIdx>0&&inputWidthIdx>0&&(inputHeightIdx+poolSzHeight)<=size(X1,1)&&(inputWidthIdx+poolSzWidth)<=size(X1,2)



                        for filterWidthIdx=1:poolSzWidth
                            inputWidthIdx=filterWidthIdx+strideHorz*(outWidthIdx-1)-paddingSzLeft;
                            for filterHeightIdx=1:poolSzHeight

                                inputHeightIdx=filterHeightIdx+strideVert*(outHeightIdx-1)-paddingSzTop;
                                inputPixel=X1(inputHeightIdx,inputWidthIdx,outChannelIdx,outBatchIdx);


                                opValue=poolingWindowFunc(opValue,inputPixel);
                            end
                        end

                    else


                        for filterWidthIdx=1:poolSzWidth
                            inputWidthIdx=filterWidthIdx+strideHorz*(outWidthIdx-1)-paddingSzLeft;
                            for filterHeightIdx=1:poolSzHeight
                                inputHeightIdx=filterHeightIdx+strideVert*(outHeightIdx-1)-paddingSzTop;


                                if inputHeightIdx>0&&inputWidthIdx>0&&inputHeightIdx<=size(X1,1)&&inputWidthIdx<=size(X1,2)
                                    inputPixel=X1(inputHeightIdx,inputWidthIdx,outChannelIdx,outBatchIdx);
                                else
                                    inputPixel=paddingValue;
                                end


                                opValue=poolingWindowFunc(opValue,inputPixel);
                            end
                        end
                    end


                    Z1(outHeightIdx,outWidthIdx,outChannelIdx,outBatchIdx)=poolingAssignFunc(opValue);
                end
            end
        end
    end
end

function Z1=iPoolingForRowMajorWithOpenMP(layer,X1,Z1,poolingWindowFunc,poolingAssignFunc,...
    paddingValue,initOpValue)

    coder.internal.prefer_const(paddingValue,initOpValue);


    [strideVert,strideHorz,poolSzHeight,poolSzWidth,...
    paddingSzTop,paddingSzLeft]=iExtractPoolingLayerParams(layer);

    outputSize=[size(Z1,4),size(Z1,3),size(Z1,2),size(Z1,1)];
    prodOutDims=numel(Z1);


    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();
    for prodOutDimsIdx=1:prodOutDims


        [outBatchIdx,outChannelIdx,outWidthIdx,outHeightIdx]=ind2sub(outputSize,prodOutDimsIdx);

        inputHeightIdx=1+strideVert*(outHeightIdx-1)-paddingSzTop;
        inputWidthIdx=1+strideHorz*(outWidthIdx-1)-paddingSzLeft;


        opValue=initOpValue;




        if inputHeightIdx>0&&inputWidthIdx>0&&(inputHeightIdx+poolSzHeight)<=size(X1,1)&&(inputWidthIdx+poolSzWidth)<=size(X1,2)



            for filterHeightIdx=1:poolSzHeight
                inputHeightIdx=filterHeightIdx+strideVert*(outHeightIdx-1)-paddingSzTop;
                for filterWidthIdx=1:poolSzWidth
                    inputWidthIdx=filterWidthIdx+strideHorz*(outWidthIdx-1)-paddingSzLeft;

                    inputPixel=X1(inputHeightIdx,inputWidthIdx,outChannelIdx,outBatchIdx);


                    opValue=poolingWindowFunc(opValue,inputPixel);
                end
            end

        else


            for filterHeightIdx=1:poolSzHeight
                inputHeightIdx=filterHeightIdx+strideVert*(outHeightIdx-1)-paddingSzTop;
                for filterWidthIdx=1:poolSzWidth
                    inputWidthIdx=filterWidthIdx+strideHorz*(outWidthIdx-1)-paddingSzLeft;


                    if inputHeightIdx>0&&inputWidthIdx>0&&inputHeightIdx<=size(X1,1)&&inputWidthIdx<=size(X1,2)
                        inputPixel=X1(inputHeightIdx,inputWidthIdx,outChannelIdx,outBatchIdx);
                    else
                        inputPixel=paddingValue;
                    end


                    opValue=poolingWindowFunc(opValue,inputPixel);
                end
            end
        end


        Z1(outHeightIdx,outWidthIdx,outChannelIdx,outBatchIdx)=poolingAssignFunc(opValue);

    end

end

function Z1=iPoolingForRowMajorWithoutOpenMP(layer,X1,Z1,poolingWindowFunc,poolingAssignFunc,...
    paddingValue,initOpValue)

    coder.internal.prefer_const(paddingValue,initOpValue);


    [strideVert,strideHorz,poolSzHeight,poolSzWidth,...
    paddingSzTop,paddingSzLeft]=iExtractPoolingLayerParams(layer);

    for outHeightIdx=1:size(Z1,1)
        for outWidthIdx=1:size(Z1,2)
            for outChannelIdx=1:size(Z1,3)
                for outBatchIdx=1:size(Z1,4)

                    inputHeightIdx=1+strideVert*(outHeightIdx-1)-paddingSzTop;
                    inputWidthIdx=1+strideHorz*(outWidthIdx-1)-paddingSzLeft;


                    opValue=initOpValue;




                    if inputHeightIdx>0&&inputWidthIdx>0&&(inputHeightIdx+poolSzHeight)<=size(X1,1)&&(inputWidthIdx+poolSzWidth)<=size(X1,2)



                        for filterHeightIdx=1:poolSzHeight
                            inputHeightIdx=filterHeightIdx+strideVert*(outHeightIdx-1)-paddingSzTop;
                            for filterWidthIdx=1:poolSzWidth
                                inputWidthIdx=filterWidthIdx+strideHorz*(outWidthIdx-1)-paddingSzLeft;

                                inputPixel=X1(inputHeightIdx,inputWidthIdx,outChannelIdx,outBatchIdx);


                                opValue=poolingWindowFunc(opValue,inputPixel);
                            end
                        end

                    else


                        for filterHeightIdx=1:poolSzHeight
                            inputHeightIdx=filterHeightIdx+strideVert*(outHeightIdx-1)-paddingSzTop;
                            for filterWidthIdx=1:poolSzWidth
                                inputWidthIdx=filterWidthIdx+strideHorz*(outWidthIdx-1)-paddingSzLeft;


                                if inputHeightIdx>0&&inputWidthIdx>0&&inputHeightIdx<=size(X1,1)&&inputWidthIdx<=size(X1,2)
                                    inputPixel=X1(inputHeightIdx,inputWidthIdx,outChannelIdx,outBatchIdx);
                                else
                                    inputPixel=paddingValue;
                                end


                                opValue=poolingWindowFunc(opValue,inputPixel);
                            end
                        end
                    end


                    Z1(outHeightIdx,outWidthIdx,outChannelIdx,outBatchIdx)=poolingAssignFunc(opValue);
                end
            end
        end
    end
end


function[hOut,wOut,cOut,bOut]=iComputeOutputSize(layer,X)
    poolSize=double(layer.PoolSize);
    stride=double(layer.Stride);
    paddingSize=double(layer.PaddingSize);
    top=1;bottom=2;left=3;right=4;


    [H,W,cOut,bOut]=size(X,1:4);

    paddingHW=[paddingSize(top)+paddingSize(bottom),paddingSize(left)+paddingSize(right)];
    outputHW=floor(([H,W]+paddingHW-poolSize)./stride+1);

    hOut=coder.const(outputHW(1));
    wOut=coder.const(outputHW(2));
end

function[strideVert,strideHorz,poolSzHeight,poolSzWidth,...
    paddingSzTop,paddingSzLeft]=iExtractPoolingLayerParams(layer)
    strideVert=layer.Stride(1);
    strideHorz=layer.Stride(2);
    poolSzHeight=layer.PoolSize(1);
    poolSzWidth=layer.PoolSize(2);
    paddingSzTop=layer.PaddingSize(1);
    paddingSzLeft=layer.PaddingSize(3);
end
