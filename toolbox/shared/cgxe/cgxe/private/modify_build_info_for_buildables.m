function modify_build_info_for_buildables(buildInfo,blockorModelH,buildableList,codegenTarget,buildConfig,bldDir)




    if(strcmp(codegenTarget,'rtw'))
        context=buildConfig;
    else
        modelH=bdroot(blockorModelH);
        cs=getActiveConfigSet(modelH);
        hwImpl=get(cs.getComponent('Hardware Implementation'));
        gencpp=get_cgxe_compiler_info(modelH);
        if gencpp
            targetLang='C++';
        else
            targetLang='C';
        end
        toolchainInfo=getToolChainInfo(buildInfo);
        context=coder.BuildConfig(codegenTarget,hwImpl,targetLang,toolchainInfo,cs,bldDir);
    end

    for buildableIdx=1:numel(buildableList)
        method=[buildableList{buildableIdx},'.updateBuildInfo'];
        feval(method,buildInfo,context);
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
