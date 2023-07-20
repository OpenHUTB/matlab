classdef AdditionCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            customLayer=coder.internal.layer.AdditionLayer(layer.Name,layer.NumInputs,layer.InputNames);
        end

    end
end
