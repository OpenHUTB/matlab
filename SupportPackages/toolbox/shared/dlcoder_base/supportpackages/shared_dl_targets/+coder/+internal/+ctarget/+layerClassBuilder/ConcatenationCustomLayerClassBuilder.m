classdef ConcatenationCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);


            internalLayer=nnet.cnn.layer.Layer.getInternalLayers(layer);
            concatenationAxis=internalLayer{1}.ConcatenationAxis;
            customLayer=coder.internal.layer.ConcatenationLayer(layer.Name,layer.NumInputs,concatenationAxis,layer.InputNames);
        end

    end
end
