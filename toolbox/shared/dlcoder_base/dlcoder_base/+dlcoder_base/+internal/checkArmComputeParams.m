function checkArmComputeParams(coderCfg,dlConfig)





    if ismac
        error(message('gpucoder:cnnconfig:unsupportedOS','arm-compute'));
    end

    if~isempty(coderCfg.GpuConfig)&&(coderCfg.GpuConfig.Enabled==1)
        error(message('gpucoder:cnnconfig:GpuConfigEnabledForCPUTargets','arm-compute'));
    end


    if(~isempty(coderCfg.Hardware))&&~(coderCfg.GenCodeOnly)
        disp(' Deploying code. This may take a few minutes. ');
    end


    checkDataType(dlConfig);


    if strcmpi(dlConfig.DataType,'int8')
        dlcoder_base.internal.validateDLquantizerObject(dlConfig);
    end

    if~coderCfg.EnableOpenMP
        error(message('gpucoder:cnnconfig:InvalidEnableOpenMPFlag','arm-compute'));
    end

end

function checkDataType(dlConfig)


    if(strcmp(dlConfig.DataType,'int8')&&...
        ~strcmp(dlConfig.ArmComputeVersion,'20.02.1')&&~strcmp(dlConfig.ArmComputeVersion,'20.11'))
        error(message('dlcoder_spkg:cnncodegen:UnsupportedACLForINT8',dlConfig.DataType,dlConfig.ArmComputeVersion));
    end


    supportedTypes={'fp32','int8'};


    if~any(strcmpi(dlConfig.DataType,supportedTypes))
        error(message('gpucoder:cnncodegen:invalid_parameter_value','DataType',strjoin(supportedTypes,', ')));
    end
end
