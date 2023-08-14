classdef FullyConnectedCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)

            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);


            [inputFormat,outputFormat]=dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(layerComp);

            isNumSpatialDimsSupported=coder.internal.layer.utils.numSpatialDims(inputFormat)==2||...
            coder.internal.layer.utils.numSpatialDims(inputFormat)==0;

            assert(isNumSpatialDimsSupported,...
            'If the input format for FullyConnectedLayer has spatial dimensions ''S'', it is expected to have two of them')

            customLayer=coder.internal.layer.FullyConnectedLayer(layer.Name,layer.Weights,layer.Bias,inputFormat{1},outputFormat{1});
        end

    end
end
