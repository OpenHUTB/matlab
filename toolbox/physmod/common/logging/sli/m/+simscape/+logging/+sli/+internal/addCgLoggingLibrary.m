function addCgLoggingLibrary(model)






    codegenMgr=coder.internal.ModelCodegenMgr.getInstance(model);
    if~isempty(codegenMgr)
        buildInfo=codegenMgr.BuildInfo;









        libName='physmod_common_logging2_core_rtw';
        if~ispc
            prefix='mw';
            libName=[prefix,libName];
        end
        buildInfo.addSysLibs(libName);
    end
end
