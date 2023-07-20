function toggleRequirementsPerspective(modelName)





    mHandle=get_param(modelName,'Handle');
    currentStudio=slreq.utils.DAStudioHelper.getActiveStudios(mHandle,false);
    reqMgr=slreq.app.MainManager.getInstance;
    reqMgr.togglePerspective(currentStudio);
