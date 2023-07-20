function X1=softsign(X1)






%#codegen


    coder.allowpcode('plain');
    coder.inline('always');



    if coder.const(isscalar(X1))
        X1=X1/(1+abs(X1));
    else
        if coder.isColumnMajor

            if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())



                for sequenceIdx=1:size(X1,5)
                    for batchIdx=1:size(X1,4)
                        for channelIdx=1:size(X1,3)
                            for widthIdx=1:size(X1,2)
                                for heightIdx=1:size(X1,1)
                                    X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                                    X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)/...
                                    (1+abs(X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)));
                                end
                            end
                        end
                    end
                end
            else


                parfor iElem=1:numel(X1)
                    X1(iElem)=X1(iElem)/(1+abs(X1(iElem)));
                end
            end
        else

            if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())


                for heightIdx=1:size(X1,1)
                    for widthIdx=1:size(X1,2)
                        for channelIdx=1:size(X1,3)
                            for batchIdx=1:size(X1,4)
                                for sequenceIdx=1:size(X1,5)
                                    X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                                    X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)/...
                                    (1+abs(X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)));
                                end
                            end
                        end
                    end
                end

            else


                outputSize=[size(X1,5),size(X1,4),size(X1,3),size(X1,2),size(X1,1)];


                coder.internal.treatAsParfor();
                coder.internal.parallelRelax();
                for elemIdx=1:numel(X1)

                    [sequenceIdx,batchIdx,channelIdx,widthIdx,heightIdx]=ind2sub(outputSize,elemIdx);
                    X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                    X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)/...
                    (1+abs(X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)));
                end
            end
        end
    end

end
