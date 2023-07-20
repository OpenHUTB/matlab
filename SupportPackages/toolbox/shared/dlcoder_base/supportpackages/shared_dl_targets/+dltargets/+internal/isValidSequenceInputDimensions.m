function isValidSequenceInputDimensions(layer,validator)




    assert(isa(layer,'nnet.cnn.layer.SequenceInputLayer'));


    inputFormat=iGetInputFormat(validator,layer.Name);

    numSpatialDimensions=nnz(ismember(inputFormat,'S'));
    if numSpatialDimensions==1||numSpatialDimensions>=3

        errorMessage=message('dlcoder_spkg:cnncodegen:unsupportedSpatialDimensions',numSpatialDimensions);
        validator.handleError(layer,errorMessage);
    end

    if nnz(ismember(inputFormat,'U'))>=1
        errorMessage=message('dlcoder_spkg:cnncodegen:unsupportedUnspecifiedDimensions');
        validator.handleError(layer,errorMessage);
    end


end

function inputFormat=iGetInputFormat(validator,layerName)
    layerInfo=validator.getLayerInfo(layerName);
    inputFormat=layerInfo.inputFormats;
    inputFormat=inputFormat{1};
end
