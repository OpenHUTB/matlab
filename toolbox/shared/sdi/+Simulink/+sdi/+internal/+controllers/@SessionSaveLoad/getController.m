function ret=getController(varargin)
    persistent ctrlObj;
    persistent saCtrlObj;
    mlock;

    appName='sdi';
    if nargin>0
        appName=varargin{1};
    end

    eng=Simulink.sdi.Instance.engine;
    if strcmpi(appName,'siganalyzer')
        if isempty(saCtrlObj)||~isvalid(saCtrlObj)
            saCtrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad(eng,'siganalyzer');
        end
        ret=saCtrlObj;
    else
        if isempty(ctrlObj)||~isvalid(ctrlObj)
            ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad(eng,'sdi');
        end
        ret=ctrlObj;
    end
end
