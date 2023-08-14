function[isValidLayer,errorMessage]=isValidSsdMergeLayer(layer,validator)








    layerInfo=validator.layerInfoMap(layer.Name);
    inputSizes=layerInfo.inputSizes;
    inputFormats=layerInfo.inputFormats;
    for iInputs=1:numel(inputSizes)




        isFormatSupported=strcmp(inputFormats{iInputs},'SSCB')||strcmp(inputFormats{iInputs},'SSC');
        assert(isFormatSupported,'Input format to ssdMergeLayer is expected to be SSCB');


        indexChannelDimension=strfind(inputFormats{iInputs},'C');
        inputChannelDimension=inputSizes{iInputs}(indexChannelDimension);
        if mod(inputChannelDimension,layer.NumChannels)~=0
            errorMessage=message('dlcoder_spkg:cnncodegen:InvalidSSDMergeLayerInputChannelSize',...
            layer.Name,layer.InputNames{iInputs},inputChannelDimension,layer.NumChannels);
            validator.handleError(layer,errorMessage);
        end
    end
end