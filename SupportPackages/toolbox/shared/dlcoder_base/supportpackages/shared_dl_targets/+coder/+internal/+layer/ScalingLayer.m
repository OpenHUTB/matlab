classdef ScalingLayer<nnet.layer.Layer&coder.internal.layer.NumericDataLayer










%#codegen


    properties
Scale
Bias
    end

    methods
        function layer=ScalingLayer(name,scale,bias)
            layer.Name=name;
            layer.Scale=scale;
            layer.Bias=bias;
        end

        function Z1=predict(layer,X1)
            coder.allowpcode('plain');
            coder.inline('always');

            if coder.isColumnMajor

                if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())
                    Z1=predictForColumnMajorWithoutOMP(layer,X1);
                else


                    Z1=predictForColumnMajorWithOMP(layer,X1);
                end
            else

                if coder.const(~coder.internal.coderNetworkUtils.canUseMultiThreading())
                    Z1=predictForRowMajorWithoutOMP(layer,X1);
                else


                    Z1=predictForRowMajorWithOMP(layer,X1);
                end
            end
        end

    end

    methods(Access=private)
        function Z1=predictForColumnMajorWithoutOMP(layer,X1)

            coder.inline('always');
            Z1=coder.nullcopy(zeros(size(X1),'like',X1));



            for sequenceIdx=1:size(Z1,5)
                for batchIdx=1:size(Z1,4)
                    for channelIdx=1:size(Z1,3)
                        for widthIdx=1:size(Z1,2)
                            for heightIdx=1:size(Z1,1)

                                Z1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                                layer.Scale*X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)+...
                                layer.Bias;
                            end
                        end
                    end
                end
            end
        end

        function Z1=predictForColumnMajorWithOMP(layer,X1)
            coder.inline('always');
            Z1=coder.nullcopy(zeros(size(X1),'like',X1));


            scale=layer.Scale;
            bias=layer.Bias;
            parfor elemIdx=1:numel(Z1)
                Z1(elemIdx)=scale*X1(elemIdx)+bias;
            end
        end

        function Z1=predictForRowMajorWithoutOMP(layer,X1)


            coder.inline('always');
            Z1=coder.nullcopy(zeros(size(X1),'like',X1));


            for heightIdx=1:size(Z1,1)
                for widthIdx=1:size(Z1,2)
                    for channelIdx=1:size(Z1,3)
                        for batchIdx=1:size(Z1,4)
                            for sequenceIdx=1:size(Z1,5)
                                Z1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                                layer.Scale*X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)+...
                                layer.Bias;
                            end
                        end
                    end
                end
            end
        end

        function Z1=predictForRowMajorWithOMP(layer,X1)

            coder.inline('always');
            Z1=coder.nullcopy(zeros(size(X1),'like',X1));

            outputSize=[size(Z1,5),size(Z1,4),size(Z1,3),size(Z1,2),size(Z1,1)];


            coder.internal.treatAsParfor();
            coder.internal.parallelRelax();



            for elemIdx=1:numel(Z1)

                [sequenceIdx,batchIdx,channelIdx,widthIdx,heightIdx]=ind2sub(outputSize,elemIdx);
                Z1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)=...
                layer.Scale*X1(heightIdx,widthIdx,channelIdx,batchIdx,sequenceIdx)+layer.Bias;
            end
        end


    end
end

