classdef BatchNormCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            inputVar=layer.TrainedVariance;
            epsilon=layer.Epsilon;
            gamma=layer.Scale;
            combinedGamma=gamma./sqrt(inputVar+epsilon);
            combinedBeta=-combinedGamma.*layer.TrainedMean+layer.Offset;
            inputFormat=dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(layerComp);

            customLayer=coder.internal.layer.BatchNormalizationLayer(layer.Name,combinedBeta,combinedGamma,inputFormat{1});
        end

    end
end
