classdef GroupedConvCustomLayerClassBuilder<coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder




    methods(Static,Access=public)

        function customLayer=convert(layerComp,converter)
            layer=dltargets.internal.getLayerFromOriginalDltNetwork(layerComp,converter.NetworkInfo);
            customLayer=coder.internal.layer.groupedconv2d(layer.Name,layer.Weights,...
            layer.Bias,layer.Stride,layer.PaddingSize,layer.DilationFactor);
        end

        function validate(layer,validator)


            if~isnumeric(layer.PaddingValue)||(layer.PaddingValue~=0)
                errorMessage=message('dlcoder_spkg:cnncodegen:PaddingValueNotSupported',layer.Name,class(layer));
                validator.handleError(layer,errorMessage);
            end

        end

    end
end
