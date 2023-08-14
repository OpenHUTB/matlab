

function saveSLCIConfigurationData(configObj,studio)

    ctx=studio.App.getAppContextManager.getCustomContext('slciApp');
    configObj.setTopModel(ctx.getTopModel());
    configObj.setFollowModelLinks(ctx.getFollowModelLinks());
    configObj.setDisableNonInlinedFuncBodyVerification(ctx.getDisableNonInlinedFuncBodyVerification());
    configObj.setTerminateOnIncompatibility(ctx.getTerminateOnIncompatibility());
    slci.Configuration.setInspectSharedUtils(ctx.getInspectSharedUtils());
    configObj.setReportFolder(ctx.getReportFolder());
    configObj.setModelAdvisorReportFolder(ctx.getModelAdvisorReportFolder())

    slci.Configuration.saveObjToFile(configObj.getModelName(),configObj)


    if ctx.getSingleFolderCodePlacement
        codePeplacement=configObj.cFlatPlacement;
        configObj.setCodeFolder(ctx.getCodeFolder);
    else
        codePeplacement=configObj.cEmbeddedCoderPlacement;
    end
    configObj.setCodePlacement(codePeplacement);