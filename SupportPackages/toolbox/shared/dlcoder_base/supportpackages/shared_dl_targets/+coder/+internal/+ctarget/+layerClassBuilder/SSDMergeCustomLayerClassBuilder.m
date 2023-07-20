classdef SSDMergeCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getDLTLayerForPIRComp(layerComp,converter.Layers);
            customLayer=coder.internal.layer.SSDMergeLayer(layer.Name,layer.NumChannels,layer.NumInputs);
        end

        function validate(layer,validator)

            coder.internal.layer.ssdMergeUtils.isValidSsdMergeLayer(layer,validator);
        end
    end
end