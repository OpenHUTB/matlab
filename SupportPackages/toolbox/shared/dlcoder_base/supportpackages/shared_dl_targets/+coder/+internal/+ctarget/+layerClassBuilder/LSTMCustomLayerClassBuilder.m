classdef LSTMCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);




            inputFormat=dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(layerComp);

            customLayer=coder.internal.layer.LSTMLayer(layer.Name,layer.NumHiddenUnits,...
            layer.InputWeights,layer.RecurrentWeights,layer.Bias,layer.CellState,...
            layer.HiddenState,layer.StateActivationFunction,layer.GateActivationFunction,...
            layer.OutputMode,inputFormat{1});
        end

        function validate(layer,validator)



            dltargets.internal.compbuilder.RNNCompBuilder.checkForMimoRNNLayer(layer,validator);
        end

    end
end
