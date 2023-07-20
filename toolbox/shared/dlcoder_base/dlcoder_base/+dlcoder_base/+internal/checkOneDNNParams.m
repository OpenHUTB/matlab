function checkOneDNNParams(coderCfg)



    errorOutForMaca64()

    if~isa(coderCfg,'coder.MexCodeConfig')
        if isempty(getenv('INTEL_MKLDNN'))
            error(message('gpucoder:cnnconfig:UnspecifiedMKLDNNlibrary'));
        end
        if~isfolder(getenv('INTEL_MKLDNN'))
            error(message('gpucoder:cnnconfig:IncorrectMKLDNNlibrary',getenv('INTEL_MKLDNN')));
        end
    end


    if~isempty(coderCfg.GpuConfig)&&(coderCfg.GpuConfig.Enabled==1)
        error(message('gpucoder:cnnconfig:GpuConfigEnabledForCPUTargets','mkldnn'));
    end



    if~coderCfg.EnableOpenMP&&isOpenMPEnabledConfiguration(coderCfg)
        warning(message('gpucoder:cnnconfig:InvalidEnableOpenMPFlagForMKLDNN'));
        coderCfg.EnableOpenMP=true;
    end

    mexCompilerCppConfig=mex.getCompilerConfigurations('c++');

    if~isempty(mexCompilerCppConfig)


        mexCompilerName=mexCompilerCppConfig.Name;
        if ispc&&isa(coderCfg,'coder.MexCodeConfig')
            if(strcmp(mexCompilerName,'MinGW64 Compiler (C++)'))
                error(message('gpucoder:cnnconfig:UnsupportedToolchainForMkldnn',mexCompilerName,'mkldnn'));
            end
        end
    end
end

function isOpenMPfiguration=isOpenMPEnabledConfiguration(cfg)
    isOpenMPfiguration=false;
    if isa(cfg,'coder.MexConfig')
        if cfg.DeepLearningConfig.UseShippingLibs==1
            isOpenMPfiguration=true;
        end
    else
        if ismac
            isOpenMPfiguration=true;
        end
    end
end

function errorOutForMaca64()


    if ismac&&strcmp(computer('arch'),'maca64')
        error(message('gpucoder:cnnconfig:UnsupportedTargetArchitectureForMacOS'));
    end
end


