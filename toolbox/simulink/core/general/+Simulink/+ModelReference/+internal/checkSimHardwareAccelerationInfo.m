function[upToDate,msg]=checkSimHardwareAccelerationInfo(cachedInfo,tgtShortName,model,iBuildArgs)




    msg=[];


    if isempty(cachedInfo)
        upToDate=true;
        return;
    end

    cpuInfo=iBuildArgs.ModelRefAnchorCPUInfo;



    cachedSIMDVer=cachedInfo.SIMDVer;

    if strcmpi(cachedSIMDVer,'sse2')
        upToDate=true;
        return;
    elseif strcmpi(cachedSIMDVer,'avx2')
        upToDate=cpuInfo.AVX2;
    elseif strcmpi(cachedSIMDVer,'avx512')
        upToDate=cpuInfo.AVX512;
    end

    if~upToDate
        msg=DAStudio.message('Simulink:slbuild:simHardwareAccelerationChanged',tgtShortName,model);
        return;
    end
end
