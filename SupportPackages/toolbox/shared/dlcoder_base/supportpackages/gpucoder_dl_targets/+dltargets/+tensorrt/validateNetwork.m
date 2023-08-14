












function validateNetwork(inputLayers,hasSequenceInput,dlcfg,errorHandler)



    if numel(inputLayers)>1&&strcmpi(dlcfg.DataType,'int8')
        msg=message('dlcoder_spkg:cnncodegen:MultiInputNotSupported',dlcfg.TargetLibrary,dlcfg.DataType);
        errorHandler.handleNetworkError(msg);
    end



    if hasSequenceInput&&strcmpi(dlcfg.DataType,'int8')
        msg=message('dlcoder_spkg:cnncodegen:LSTMNetworkNotSupportedForINT8',dlcfg.TargetLibrary,dlcfg.DataType);
        errorHandler.handleNetworkError(msg);
    end

end


