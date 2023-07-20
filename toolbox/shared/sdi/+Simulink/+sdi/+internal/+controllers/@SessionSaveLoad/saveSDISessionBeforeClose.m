function saveSDISessionBeforeClose(varargin)



    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    if ctrlObj.ActionInProgress
        beep;
    else
        ctrlObj.saveSessionBeforeClose(varargin{:});
    end
end
