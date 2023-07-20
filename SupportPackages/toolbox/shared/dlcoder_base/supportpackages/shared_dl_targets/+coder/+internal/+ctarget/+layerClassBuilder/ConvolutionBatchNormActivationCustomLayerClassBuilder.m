classdef ConvolutionBatchNormActivationCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function externalCustomLayer=convert(layer,~)

            layerName=coder.internal.ctarget.layerClassBuilder.utils.getFusedLayerName(layer);

            convLayer=layer.OriginalLayers{1};
            bnLayer=layer.OriginalLayers{2};
            inputVar=bnLayer.TrainedVariance;
            epsilon=bnLayer.Epsilon;
            gamma=bnLayer.Scale.HostValue;
            combinedGamma=gamma./sqrt(inputVar+epsilon);
            combinedBeta=-combinedGamma.*bnLayer.TrainedMean+bnLayer.Offset.HostValue;

            if numel(layer.OriginalLayers)==3
                externalCustomLayer=coder.internal.layer.convBN2dRelu(layerName,...
                convLayer.Weights.HostValue,convLayer.Bias.HostValue,convLayer.Stride,...
                convLayer.PaddingSize,convLayer.DilationFactor,combinedBeta,combinedGamma);
            else
                externalCustomLayer=coder.internal.layer.convBN2d(layerName,...
                convLayer.Weights.HostValue,convLayer.Bias.HostValue,convLayer.Stride,...
                convLayer.PaddingSize,convLayer.DilationFactor,combinedBeta,combinedGamma);
            end
        end

    end
end
