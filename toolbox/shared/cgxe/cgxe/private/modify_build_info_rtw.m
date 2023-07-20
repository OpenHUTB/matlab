function modify_build_info_rtw(blockorModelH,srcFiles,incFiles,incPaths,linkObjs,linkFlags,nonBuildFiles)



    modelH=bdroot(blockorModelH);
    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(get_param(modelH,'Name'));
    if isempty(modelCodegenMgr)
        return;
    end
    buildInfo=modelCodegenMgr.BuildInfo;
    modify_build_info(buildInfo,srcFiles,incFiles,incPaths,...
    linkObjs,linkFlags,nonBuildFiles);

end
