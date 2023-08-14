function modify_buildInfo_for_coder_rtw(blockorModelH,buildableList)



    modelH=bdroot(blockorModelH);
    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(get_param(modelH,'Name'));
    buildInfo=modelCodegenMgr.BuildInfo;
    modify_buildInfo_for_coder(buildInfo,buildableList);

end
