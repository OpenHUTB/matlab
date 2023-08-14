











function validateNetwork(inputLayers,dlcfg,errorHandler)


    if numel(inputLayers)>1&&strcmpi(dlcfg.DataType,'int8')
        msg=message('dlcoder_spkg:cnncodegen:MultiInputNotSupported',dlcfg.TargetLibrary,dlcfg.DataType);
        errorHandler.handleNetworkError(msg);
    end
end
