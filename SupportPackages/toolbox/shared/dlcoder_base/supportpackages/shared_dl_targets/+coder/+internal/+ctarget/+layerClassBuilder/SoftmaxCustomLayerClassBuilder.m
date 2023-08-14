classdef SoftmaxCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);


            inputFormat=dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(layerComp);
            channelDim=strfind(inputFormat{1},'C');

            customLayer=coder.internal.layer.SoftmaxLayer(layer.Name,channelDim);
        end
    end
end
