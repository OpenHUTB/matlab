classdef InputCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)
        function customLayer=convert(layerComp,converter)
            inputLayer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            inputFormat=dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(layerComp);

            customLayer=coder.internal.layer.InputLayer(inputLayer.Name,inputLayer.InputSize,...
            inputFormat,inputLayer.Normalization,inputLayer.Mean,inputLayer.StandardDeviation,...
            inputLayer.Min,inputLayer.Max);
        end

        function validate(layer,validator)
            dltargets.internal.isValidInputNormalization(layer,validator);
            dltargets.internal.validateSplitComplexInputs(layer,validator);
        end
    end
end
