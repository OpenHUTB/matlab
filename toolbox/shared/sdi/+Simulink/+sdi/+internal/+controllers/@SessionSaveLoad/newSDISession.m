function newSDISession(varargin)
    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    if ctrlObj.ActionInProgress
        beep;
    else
        ctrlObj.newSession(varargin{:});
    end
end
