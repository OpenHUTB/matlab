classdef FlattenCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,~)




            [inputFormat,outputFormat]=...
            dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(layerComp);
            layerName=layerComp.getName;

            customLayer=coder.internal.layer.FlattenLayer(layerName,inputFormat,outputFormat);
        end

    end
end
