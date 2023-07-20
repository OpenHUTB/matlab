function supportedLibs=getSupportedTargetLibs()







    import matlab.internal.lang.capability.Capability










    if(Capability.isSupported(Capability.LocalClient))
        supportedGpuLibs={'cudnn','tensorrt','arm-compute-mali'};
    else
        supportedGpuLibs={'cudnn','tensorrt'};
    end
    supportedCpuLibs={'mkldnn','onednn','arm-compute','none','cmsis-nn'};

    supportedLibs=supportedCpuLibs;

    if~isempty(which('coder.gpuConfig'))
        supportedLibs=[supportedGpuLibs,supportedLibs];
    end

end
