function loadSDIView(varargin)

    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    tmp=onCleanup(@()updateGUITitle(ctrlObj));
    if ctrlObj.ActionInProgress
        beep;
    else
        ctrlObj.ActionInProgress=true;
        tmp2=onCleanup(@()Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,false));

        if nargin>0&&~isempty(varargin{1})
            fullFileName=varargin{1};
        else
            MLDATXFilter=getString(message('SDI:sdi:MLDATXFilter'));
            MLDATXDesc=getString(message('SDI:sdi:MLDATXDesc'));
            MLDATXLoadTitle=getString(message('SDI:sdi:MLDATXLoadTitle'));
            [filename,pathname]=...
            uigetfile({MLDATXFilter,MLDATXDesc},MLDATXLoadTitle);
            if isequal(filename,0)||isequal(pathname,0)
                return;
            end
            fullFileName=fullfile(pathname,filename);
        end

        Simulink.sdi.loadView(fullFileName);
    end
end
