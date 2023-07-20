function X=hardsigmoid(X)





%#codegen


    coder.allowpcode('plain');
    coder.inline('always');






    if coder.const(isscalar(X))
        X=max(0,min(1,0.2.*X+0.5,'includenan'),'includenan');
    else
        if coder.isColumnMajor

            if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())



                for sequenceIdx=1:size(X,5)
                    for batchIdx=1:size(X,4)
                        for channelIdx=1:size(X,3)
                            for widthIdx=1:size(X,2)
                                for heightIdx=1:size(X,1)
                                    X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                                    max(0,min(1,0.2.*X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)+...
                                    0.5,'includenan'),'includenan');
                                end
                            end
                        end
                    end
                end
            else


                parfor iElem=1:numel(X)
                    X(iElem)=max(0,min(1,0.2.*X(iElem)+0.5,'includenan'),'includenan');
                end
            end
        else

            if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())


                for heightIdx=1:size(X,1)
                    for widthIdx=1:size(X,2)
                        for channelIdx=1:size(X,3)
                            for batchIdx=1:size(X,4)
                                for sequenceIdx=1:size(X,5)
                                    X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                                    max(0,min(1,0.2.*X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)+...
                                    0.5,'includenan'),'includenan');
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

                    sequenceIdx=coder.internal.indexInt(sequenceIdx);
                    batchIdx=coder.internal.indexInt(batchIdx);
                    channelIdx=coder.internal.indexInt(channelIdx);
                    widthIdx=coder.internal.indexInt(widthIdx);
                    heightIdx=coder.internal.indexInt(heightIdx);

                    X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                    max(0,min(1,0.2.*X(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)+...
                    0.5,'includenan'),'includenan');
                end
            end
        end
    end

end
