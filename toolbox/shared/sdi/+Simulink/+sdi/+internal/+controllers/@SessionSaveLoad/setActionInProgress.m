function setActionInProgress(appName,isInProgress)

    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    ctrlObj.ActionInProgress=isInProgress;
end