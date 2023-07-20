


function loadSLCIConfigurationData(configObj,studio)

    ctx=studio.App.getAppContextManager.getCustomContext('slciApp');
    ctx.setTopModel(configObj.getTopModel());
    ctx.setFollowModelLinks(configObj.getFollowModelLinks());
    ctx.setTerminateOnIncompatibility(configObj.getTerminateOnIncompatibility());
    ctx.setInspectSharedUtils(configObj.getInspectSharedUtils());
    ctx.setDisableNonInlinedFuncBodyVerification(configObj.getDisableNonInlinedFuncBodyVerification());
    ctx.setReportFolder(configObj.getReportFolder());
    ctx.setModelAdvisorReportFolder(configObj.getModelAdvisorReportFolder())

    if strcmp(configObj.getCodePlacement,configObj.cFlatPlacement)
        ctx.setSingleFolderCodePlacement(true);
        ctx.setCodeFolder(configObj.getCodeFolder);
    else
        ctx.setSingleFolderCodePlacement(false);
    end

