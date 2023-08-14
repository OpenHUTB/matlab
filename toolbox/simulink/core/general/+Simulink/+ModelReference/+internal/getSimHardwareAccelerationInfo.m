function rebuildInfo=getSimHardwareAccelerationInfo(modelName,mdlRefTgtType)




    rebuildInfo=[];

    if~(strcmpi(mdlRefTgtType,'SIM')&&strcmpi(get_param(modelName,'SimHardwareAcceleration'),'native'))
        return;
    end

    hSTL=get_param(modelName,'SimTargetFcnLibHandle');
    if~strcmp(hSTL.LoadedLibrary,'Simulation Target IPP BLAS SIMD')
        return;
    end

    cpuInfo=get_param(modelName,'ModelRefAnchorCPUInfo');
    if cpuInfo.AVX512
        simd="AVX512";
    elseif cpuInfo.AVX2
        simd="AVX2";
    elseif cpuInfo.SSE2
        simd="SSE2";
    else
        simd='';
    end
    if~isempty(simd)
        rebuildInfo.SIMDVer=simd;
    end
end
