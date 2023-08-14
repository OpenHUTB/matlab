classdef AvgPoolingCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);


            [poolSize,stride,actualPaddingSize]=...
            coder.internal.layer.poolingUtils.getPoolingParameters(layer,converter);

            customLayer=coder.internal.layer.AveragePooling2DLayer(layer.Name,poolSize,...
            stride,actualPaddingSize);
        end

        function validate(layer,validator)

            if isa(layer,'nnet.cnn.layer.AveragePooling2DLayer')

                if~isnumeric(layer.PaddingValue)||(layer.PaddingValue~=0)
                    errorMessage=message('dlcoder_spkg:cnncodegen:PaddingValueNotSupported',layer.Name,class(layer));
                    validator.handleError(layer,errorMessage);
                end
            end
        end
    end
end
