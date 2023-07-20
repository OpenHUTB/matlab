function X=batchNormOpInPlaceWithSpatialDims(layer,elementwiseFunction,X)





%#codegen


    coder.inline('always');
    coder.allowpcode('plain');

    if coder.isColumnMajor

        X=iBatchNormForColumnMajor(layer,elementwiseFunction,X);
    else

        X=iBatchNormForRowMajor(layer,elementwiseFunction,X);
    end

end

function X=iBatchNormForColumnMajor(layer,elementwiseFunction,X)

    coder.inline('always');



    for sequenceIdx=1:size(X,5)
        for batchIdx=1:size(X,4)
            for channelIdx=1:size(X,3)

                combinedGamma=layer.CombinedGamma(1,1,channelIdx);
                combinedBeta=layer.CombinedBeta(1,1,channelIdx);
                for widthIdx=1:size(X,2)
                    for heightIdx=1:size(X,1)
                        X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=elementwiseFunction(combinedGamma*...
                        X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)+combinedBeta);
                    end
                end
            end
        end
    end

end

function X=iBatchNormForRowMajor(layer,elementwiseFunction,X)

    coder.inline('always');



    for heightIdx=1:size(X,1)
        for widthIdx=1:size(X,2)
            for channelIdx=1:size(X,3)

                combinedGamma=layer.CombinedGamma(1,1,channelIdx);
                combinedBeta=layer.CombinedBeta(1,1,channelIdx);
                for batchIdx=1:size(X,4)
                    for sequenceIdx=1:size(X,5)
                        X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=elementwiseFunction(combinedGamma*...
                        X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)+combinedBeta);
                    end
                end
            end
        end
    end

end