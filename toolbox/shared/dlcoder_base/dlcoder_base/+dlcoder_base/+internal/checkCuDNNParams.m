
function dlConfig=checkCuDNNParams(coderCfg,dlConfig)



    assert(isa(dlConfig,'coder.CuDNNConfig'));
    if isempty(coderCfg.GpuConfig)||~coderCfg.GpuConfig.Enabled
        error(message('gpucoder:cnnconfig:MissingGpuConfig',dlConfig.TargetLibrary));
    end


    checkDataType(dlConfig);


    if strcmpi(dlConfig.DataType,'int8')
        dlcoder_base.internal.validateDLquantizerObject(dlConfig);
    end


    if strcmpi(dlConfig.DataType,'int8')
        dlcoder_base.internal.validateComputeCapability(coderCfg,'INT8','6.1');
    end

    if~islogical(dlConfig.AutoTuning)
        error(message('gpucoder:cnncodegen:invalid_parameter_value','autotuning','true or false'));
    end
end

function checkDataType(dlConfig)



    supportedTypes={'fp32','int8'};

    if dlcoderfeature('cuDNNFp16')
        supportedTypes=[supportedTypes,'fp16'];
    end





    if~any(strcmpi(dlConfig.DataType,supportedTypes))
        error(message('gpucoder:cnncodegen:invalid_parameter_value','DataType',strjoin(supportedTypes,', ')));
    end
end


