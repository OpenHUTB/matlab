function validateSplitComplexInputs(layer,validator)






    if layer.SplitComplexInputs
        errorMessage=message('dlcoder_spkg:cnncodegen:UnsupportedComplexInput',layer.Name);
        validator.handleError(layer,errorMessage);
    end
end
