function updateGUITitleAfterSessionLoad(appName)

    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    ctrlObj.updateGUITitle();
end