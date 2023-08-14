function[lToolchainInfo,lToolchainInfoError]=getToolchainInfoFromConfigParam...
    (tcName,lMexCompilerKey,isGPU,isGPUHardware)




    isDefaultToolchain=isempty(tcName)||...
    strcmpi(tcName,coder.make.internal.getInfo('default-toolchain'));

    if isDefaultToolchain
        [lToolchainInfo,lToolchainInfoError]=i_getDefaultToolchainInfo(lMexCompilerKey,isGPU,isGPUHardware);
    else
        [lToolchainInfo,lToolchainInfoError]=...
        coder.make.internal.getToolchainInfoFromRegistry(tcName);
    end



    function[lToolchainInfo,lToolchainInfoError]=i_getDefaultToolchainInfo(lMexCompilerKey,isGPU,isGPUHardware)

        tcStruct=coder.make.internal.getMexCompilerInfo('installedOrFirstSupported');

        if isGPU
            if isGPUHardware
                [lToolchainName,toolchainAlias]=coder.make.internal.getNvidiaSpkgToolchain(isGPU);
            else
                [lToolchainName,toolchainAlias]=coder.internal.getGPUToolchainName(tcStruct);
            end
        elseif isGPUHardware
            [lToolchainName,toolchainAlias]=coder.make.internal.getNvidiaSpkgToolchain(isGPU);
        elseif~isempty(lMexCompilerKey)
            [lToolchainName,toolchainAlias]=...
            coder.make.internal.getToolchainNameFromRegistry(lMexCompilerKey);
        else
            toolchainAlias=tcStruct.compStr;
            lToolchainName=...
            coder.make.internal.getToolchainNameFromRegistry(toolchainAlias);
        end




        [lToolchainInfo,lToolchainInfoError]=...
        coder.make.internal.getToolchainInfoFromRegistry(lToolchainName,toolchainAlias);

