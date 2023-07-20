function X=elementwiseOperationInPlace(elementwiseFunction,X)





%#codegen



    coder.inline('always');
    coder.allowpcode('plain');

    if coder.isColumnMajor


        if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())

            X=lambdaForColumnMajorWithoutOMP(elementwiseFunction,X);
        else

            parfor iElem=1:numel(X)
                X(iElem)=elementwiseFunction(X(iElem));%#ok
            end
        end
    else

        if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())


            X=lambdaForRowMajorWithoutOMP(elementwiseFunction,X);
        else

            X=lambdaForRowMajorWithOMP(elementwiseFunction,X);
        end
    end

end

function X=lambdaForColumnMajorWithoutOMP(elementwiseFunction,X)

    coder.inline('always');




    for sequenceIdx=1:size(X,5)
        for batchIdx=1:size(X,4)
            for channelIdx=1:size(X,3)
                for widthIdx=1:size(X,2)
                    for heightIdx=1:size(X,1)
                        X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                        elementwiseFunction(X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx));
                    end
                end
            end
        end
    end

end

function X=lambdaForRowMajorWithoutOMP(elementwiseFunction,X)

    coder.inline('always');




    for heightIdx=1:size(X,1)
        for widthIdx=1:size(X,2)
            for channelIdx=1:size(X,3)
                for batchIdx=1:size(X,4)
                    for sequenceIdx=1:size(X,5)

                        X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                        elementwiseFunction(X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx));
                    end
                end
            end
        end
    end

end

function X=lambdaForRowMajorWithOMP(elementwiseFunction,X)

    coder.inline('always');


    outputSize=[size(X,5),size(X,4),size(X,3),size(X,2),size(X,1)];


    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();




    for elemIdx=1:numel(X)

        [sequenceIdx,batchIdx,channelIdx,widthIdx,heightIdx]=ind2sub(outputSize,elemIdx);
        X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
        elementwiseFunction(X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx));
    end

end

