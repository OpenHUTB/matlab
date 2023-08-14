function isValidInputNormalization(layer,codegenLayerValidator)




    layerNormalization=layer.Normalization;
    if isa(layerNormalization,'function_handle')
        errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_input_normalization');
        codegenLayerValidator.handleError(layer,errorMessage);
    end

    supportedNormalizationTypes={'zerocenter','zscore','rescale-symmetric','rescale-zero-one','none'};
    if~any(strcmpi(layerNormalization,supportedNormalizationTypes))
        errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_invalid_normalization',layerNormalization);
        codegenLayerValidator.handleError(layer,errorMessage);
    end

    if strcmp(layerNormalization,'rescale-symmetric')||strcmp(layerNormalization,'rescale-zero-one')

        if isequal(layer.Min,layer.Max)
            errorMessage=message('dlcoder_spkg:cnncodegen:InvalidMinMaxValueForInputNormalization',layer.Name,layerNormalization);
            codegenLayerValidator.handleError(layer,errorMessage);
        end
    end

end

