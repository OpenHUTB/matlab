function saveSDISession(varargin)
    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    if ctrlObj.ActionInProgress
        beep;
    else
        if nargin>0
            varargin{1}=strcmpi(varargin{1},'saveAs');
        end
        ctrlObj.saveSession(varargin{:});
    end
end
