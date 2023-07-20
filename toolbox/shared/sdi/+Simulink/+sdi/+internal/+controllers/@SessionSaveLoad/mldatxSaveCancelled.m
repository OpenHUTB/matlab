function mldatxSaveCancelled(appName)

    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',ctrlObj.AppName));
    ctrlObj.cacheSessionInfo(ctrlObj.OriginalFileName,ctrlObj.OriginalPathName);
    ctrlObj.Dirty=ctrlObj.OriginalDirtyFlag;
    ctrlObj.ActionInProgress=false;
end