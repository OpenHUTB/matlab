function modify_build_info_for_buildables_rtw(blockorModelH,buildableList,codegenTarget,buildConfig)



    if(isempty(buildConfig))


        return;
    end

    modelH=bdroot(blockorModelH);
    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(get_param(modelH,'Name'));
    if isempty(modelCodegenMgr)
        return;
    end
    buildInfo=modelCodegenMgr.BuildInfo;
    modify_build_info_for_buildables(buildInfo,blockorModelH,buildableList,codegenTarget,buildConfig,modelCodegenMgr.BuildDirectory);

end
