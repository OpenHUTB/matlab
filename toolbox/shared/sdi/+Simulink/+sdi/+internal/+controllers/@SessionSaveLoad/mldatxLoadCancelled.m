function mldatxLoadCancelled(varargin)

    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName',ctrlObj.AppName));
    ctrlObj.ActionInProgress=false;
end