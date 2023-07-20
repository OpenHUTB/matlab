classdef ZeroPadding2dCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            customLayer=coder.internal.layer.ZeroPadding2dLayer(layer.Name,layer.Top,layer.Bottom,layer.Left,layer.Right);
        end

    end
end
