function X=sigmoid(X)






%#codegen


    coder.allowpcode('plain');
    coder.inline('always');



    if coder.const(isscalar(X))
        X=1/(1+exp(-X));
    else
        if coder.isColumnMajor

            if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())



                for sequenceIdx=1:size(X,5)
                    for batchIdx=1:size(X,4)
                        for channelIdx=1:size(X,3)
                            for widthIdx=1:size(X,2)
                                for heightIdx=1:size(X,1)
                                    X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=1/(1+...
                                    exp(-X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)));
                                end
                            end
                        end
                    end
                end
            else


                parfor iElem=1:numel(X)
                    X(iElem)=1/(1+exp(-X(iElem)));
                end
            end
        else

            if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())


                for heightIdx=1:size(X,1)
                    for widthIdx=1:size(X,2)
                        for channelIdx=1:size(X,3)
                            for batchIdx=1:size(X,4)
                                for sequenceIdx=1:size(X,5)

                                    X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=1/(1+...
                                    exp(-X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)));
                                end
                            end
                        end
                    end
                end

            else


                outputSize=[size(X,5),size(X,4),size(X,3),size(X,2),size(X,1)];


                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for elemIdx=1:numel(X)

                    [sequenceIdx,batchIdx,channelIdx,widthIdx,heightIdx]=ind2sub(outputSize,elemIdx);
                    X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=1/(1+...
                    exp(-X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)));
                end
            end
        end
    end

end
