classdef GRUCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);




            inputFormat=dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(layerComp);

            customLayer=coder.internal.layer.GruLayer(layer.Name,layer.NumHiddenUnits,layer.InputWeights,...
            layer.RecurrentWeights,layer.Bias,layer.HiddenState,layer.StateActivationFunction,...
            layer.GateActivationFunction,layer.ResetGateMode,layer.OutputMode,inputFormat{1});
        end


        function validate(layer,validator)


            supportedResetGateModes={'after-multiplication','before-multiplication','recurrent-bias-after-multiplication'};
            if~any(ismember(layer.ResetGateMode,supportedResetGateModes))
                errorMessage=message('dlcoder_spkg:cnncodegen:UnsupportedResetGateMode',layer.ResetGateMode);
                validator.handleError(layer,errorMessage);
            end



            dltargets.internal.compbuilder.RNNCompBuilder.checkForMimoRNNLayer(layer,validator);
        end

    end
end
