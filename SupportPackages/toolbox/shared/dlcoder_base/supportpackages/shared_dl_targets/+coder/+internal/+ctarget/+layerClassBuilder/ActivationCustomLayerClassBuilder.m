classdef ActivationCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            [activationFunctionType,activationParameters]=nnet.internal.cnn.util.getActivationFunctionTypeAndParams(layer);
            customLayer=coder.internal.layer.ActivationLayer(layer.Name,activationFunctionType,activationParameters);
        end

    end
end
