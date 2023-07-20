classdef MaxPoolingCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);


            [poolSize,stride,actualPaddingSize]=...
            coder.internal.layer.poolingUtils.getPoolingParameters(layer,converter);

            customLayer=coder.internal.layer.MaxPooling2DLayer(layer.Name,poolSize,...
            stride,actualPaddingSize);
        end

        function validate(layer,validator)


            if isa(layer,'nnet.cnn.layer.MaxPooling2DLayer')&&layer.HasUnpoolingOutputs


                errorMessage=message('dlcoder_spkg:cnncodegen:HasUnpoolingOutputsUnsupported');
                validator.handleError(layer,errorMessage);
            end
        end
    end
end
