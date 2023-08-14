classdef ScalingCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            if isa(layer,'rl.layer.ScalingLayer')
                bias=layer.Bias;
            else
                assert(isa(layer,'nnet.inceptionresnetv2.layer.ScalingFactorLayer'))
                bias=0;
            end
            customLayer=coder.internal.layer.ScalingLayer(layer.Name,layer.Scale,bias);
        end

    end
end
