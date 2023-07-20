function validateGPUCoderSettings(config)





    if isprop(config,'GpuConfig')&&...
        ~isempty(config.GpuConfig)&&...
        config.GpuConfig.Enabled
        forceGpuCoderSettings(config);

        if isHostUnifiedCodegen(config)
            btStruct=warning('QUERY','BACKTRACE');
            warning('OFF','BACKTRACE');
            warning(message('gpucoder:common:HostUnifiedModeWarning'));
            warning(btStruct);
        end
    end
end

function result=isHostUnifiedCodegen(config)
    isUnified=isprop(config.GpuConfig,'MallocMode')&&...
    strcmpi(config.GpuConfig.MallocMode,'unified');
    if~isUnified
        result=false;
        return;
    end
    isNvidiaBoardTarget=isprop(config,'Hardware')&&...
    ~isempty(config.Hardware)&&...
    isprop(config.Hardware,'Name')&&...
    any(strcmpi(config.Hardware.Name,{'NVIDIA Jetson','NVIDIA Drive'}));
    result=isUnified&&~isNvidiaBoardTarget;
end
