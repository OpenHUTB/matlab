function loadSDISession(varargin)
    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    if ctrlObj.ActionInProgress
        beep;
    else
        ctrlObj.loadSession(varargin{:});
    end
end
