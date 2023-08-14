function[rootDir]=getSpkgRoot(target)





    switch target
    case{'cudnn','tensorrt','arm_mali'}
        [flag,rootDir]=dlcoder_base.internal.isGpuCoderDLTargetsInstalled;
    case{'arm_neon','mkldnn','onednn','none','cmsis-nn'}
        [flag,rootDir]=dlcoder_base.internal.isMATLABCoderDLTargetsInstalled;
    otherwise
        error(message('gpucoder:cnnconfig:unsupported_target_lib',target,'cudnn, tensorrt, mkldnn, arm-compute, cmsis-nn and none'));
    end

    if~flag

        assert(isempty(rootDir));
        rootDir='';
    end


end
