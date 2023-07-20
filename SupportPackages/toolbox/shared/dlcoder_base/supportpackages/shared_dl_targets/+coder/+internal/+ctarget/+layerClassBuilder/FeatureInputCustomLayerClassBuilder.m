classdef FeatureInputCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.InputCustomLayerClassBuilder




    methods(Static,Access=public)
        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            inputFormat=converter.getLayerInfo(layer.Name).inputFormats;




            customLayer=coder.internal.layer.InputLayer(layer.Name,layer.InputSize,inputFormat,...
            layer.Normalization,layer.Mean',layer.StandardDeviation',layer.Min',layer.Max');
        end
    end
end
