classdef SequenceFoldingCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)




            [inputFormat,outputFormat]=...
            dltargets.internal.utils.getInputAndOutputFormatsFromPirComp(layerComp);
            layerName=layerComp.getName;
            miniBatchSize=getBatchSize(converter.NetworkInfo);

            customLayer=coder.internal.layer.SequenceFoldingLayer(layerName,inputFormat,outputFormat,miniBatchSize);
        end

        function validate(layer,validator)




            if~dlcoderfeature('SupportFoldAndUnfoldLayersInOriginalGraph')
                layerType=class(layer);
                layerClassName=dltargets.internal.compbuilder.CodegenCompBuilder.getLayerName(layer,layerType);
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_layer',layerClassName,validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end
        end
    end
end
