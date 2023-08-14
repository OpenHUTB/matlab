function buildConfig=generateBuildConfig(configInfo,bldDir)



    if isa(configInfo,'coder.CodeConfig')
        cgt='rtw';
    else
        cgt='mex';
    end

    if isprop(configInfo,'HardwareImplementation')
        hwi=configInfo.HardwareImplementation;
    else
        hwi=coder.HardwareImplementation;
    end
    if isprop(configInfo,'TargetLang')
        tl=configInfo.TargetLang;
    else
        tl='C';
    end

    tci=getToolChainInfo(configInfo,tl);
    canCopyToBuildDir=true;
    buildConfig=coder.BuildConfig(cgt,hwi,tl,tci,configInfo,bldDir,canCopyToBuildDir);
end


function tci=getToolChainInfo(configInfo,tl)
    if isa(configInfo,'coder.MexConfig')


        try
            cc=emcGetMexCompiler(tl);
            tciName=cc(1).Name;
        catch
            tciName='';
        end
        tci=coder.make.internal.getEmptyToolchainForMex(tciName);
    else
        if isprop(configInfo,'Toolchain')
            tci=coder.make.internal.getToolchainInfoFromName(configInfo.Toolchain);
        else
            tci=[];
        end
    end
end

