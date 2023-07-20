function Z=elementwiseOperation(elementwiseFunction,X,protoTypeData)





%#codegen


    coder.inline('always');
    coder.allowpcode('plain');

    Z=coder.nullcopy(zeros(size(X),'like',protoTypeData));

    if coder.isColumnMajor


        if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())

            Z=lambdaForColumnMajorWithoutOMP(elementwiseFunction,X,protoTypeData);
        else

            parfor iElem=1:numel(X)
                Z(iElem)=elementwiseFunction(X(iElem));%#ok
            end
        end
    else

        if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())

            Z=lambdaForRowMajorWithoutOMP(elementwiseFunction,X,protoTypeData);
        else

            Z=lambdaForRowMajorWithOMP(elementwiseFunction,X,protoTypeData);
        end
    end

end

function Z=lambdaForColumnMajorWithoutOMP(elementwiseFunction,X,protoTypeData)

    coder.inline('always');
    Z=coder.nullcopy(zeros(size(X),'like',protoTypeData));




    for sequenceIdx=1:size(X,5)
        for batchIdx=1:size(X,4)
            for channelIdx=1:size(X,3)
                for widthIdx=1:size(X,2)
                    for heightIdx=1:size(X,1)
                        Z(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                        elementwiseFunction(X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx));
                    end
                end
            end
        end
    end

end

function Z=lambdaForRowMajorWithoutOMP(elementwiseFunction,X,protoTypeData)

    coder.inline('always');
    Z=coder.nullcopy(zeros(size(X),'like',protoTypeData));




    for heightIdx=1:size(X,1)
        for widthIdx=1:size(X,2)
            for channelIdx=1:size(X,3)
                for batchIdx=1:size(X,4)
                    for sequenceIdx=1:size(X,5)

                        Z(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                        elementwiseFunction(X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx));
                    end
                end
            end
        end
    end

end

function Z=lambdaForRowMajorWithOMP(elementwiseFunction,X,protoTypeData)

    coder.inline('always');
    Z=coder.nullcopy(zeros(size(X),'like',protoTypeData));



    outputSize=[size(X,5),size(X,4),size(X,3),size(X,2),size(X,1)];


    coder.internal.treatAsParfor();
    coder.internal.parallelRelax();




    for elemIdx=1:numel(X)

        [sequenceIdx,batchIdx,channelIdx,widthIdx,heightIdx]=ind2sub(outputSize,elemIdx);
        Z(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
        elementwiseFunction(X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx));
    end

end
