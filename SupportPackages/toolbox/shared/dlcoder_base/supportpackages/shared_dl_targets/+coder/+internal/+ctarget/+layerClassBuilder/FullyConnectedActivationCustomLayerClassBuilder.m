classdef FullyConnectedActivationCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function externalCustomLayer=convert(layer,~)
            layerName=coder.internal.ctarget.layerClassBuilder.utils.getFusedLayerName(layer);

            externalCustomLayer=coder.internal.layer.FullyConnectedActivation(layerName,layer.Weights,...
            layer.Bias,layer.InputSize,layer.OutputSize,layer.ActivationParams,layer.ActivationFunctionType);
        end

    end
end
