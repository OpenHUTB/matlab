function sessionInfo=getSDISessionInfo(varargin)
    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    sessionInfo=ctrlObj.getSessionInfo(varargin{:});
end
