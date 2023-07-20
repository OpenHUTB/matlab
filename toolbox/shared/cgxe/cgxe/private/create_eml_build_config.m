





function bc=create_eml_build_config(blkId)
    modelH=bdroot(blkId);
    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance([]);

    if~isempty(modelCodegenMgr)
        cs=getActiveConfigSet(modelH);
        bf=modelCodegenMgr.BuildInfo;
        hwImpl=get(cs.getComponent('Hardware Implementation'));
        if CGXE.Utils.isRaccelOrMdfRefSimTarget(bdroot)
            targetLang=cs.get_param('SimTargetLang');
        else
            targetLang=cs.get_param('TargetLang');
        end
        toolchainInfo=getToolChainInfo(bf);
        bc=coder.BuildConfig('rtw',hwImpl,targetLang,toolchainInfo,cs,modelCodegenMgr.BuildDirectory);
    else
        bc=[];
    end
end


function tci=getToolChainInfo(buildInfo)
    tci=[];
    try
        tci=buildInfo.getBuildToolInfo('ToolchainInfo');
    catch
    end
    if isempty(tci)

        try
            compilerInfo=compilerman('get_compiler_info');
            tciName=compilerInfo.compilerFullName;
        catch
            tciName='';
        end
        tci=coder.make.internal.createEmptyToolchain(tciName);
    end

end

