function X=batchNormOpInPlaceWithoutSpatialDims(layer,elementwiseFunction,X)





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



    for sequenceIdx=1:size(X,3)
        for batchIdx=1:size(X,2)
            for channelIdx=1:size(X,1)
                X(channelIdx,batchIdx,sequenceIdx)=elementwiseFunction(layer.CombinedGamma(channelIdx)*...
                X(channelIdx,batchIdx,sequenceIdx)+layer.CombinedBeta(channelIdx));
            end
        end
    end

end

function X=iBatchNormForRowMajor(layer,elementwiseFunction,X)

    coder.inline('always');



    for channelIdx=1:size(X,1)

        combinedGamma=layer.CombinedGamma(channelIdx);
        combinedBeta=layer.CombinedBeta(channelIdx);
        for batchIdx=1:size(X,2)
            for sequenceIdx=1:size(X,3)
                X(channelIdx,batchIdx,sequenceIdx)=elementwiseFunction(combinedGamma*...
                X(channelIdx,batchIdx,sequenceIdx)+combinedBeta);
            end
        end
    end

end