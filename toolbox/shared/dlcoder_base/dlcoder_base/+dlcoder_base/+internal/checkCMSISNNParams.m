function checkCMSISNNParams(coderCfg,dlConfig)




    assert(isa(dlConfig,'coder.CMSISNNConfig'));

    if~isempty(coderCfg.GpuConfig)&&(coderCfg.GpuConfig.Enabled==1)
        error(message('gpucoder:cnnconfig:GpuConfigEnabledForCPUTargets',dlConfig.TargetLibrary));
    end

end
