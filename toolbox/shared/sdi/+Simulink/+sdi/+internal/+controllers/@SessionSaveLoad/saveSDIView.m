function saveSDIView(varargin)

    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    if ctrlObj.ActionInProgress
        beep;
    else
        tmp=onCleanup(@()updateGUITitle(ctrlObj));
        ctrlObj.ActionInProgress=true;
        tmp2=onCleanup(@()Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,false));


        if nargin>1&&strcmpi(varargin{1},'saveAs')&&...
            ~isempty(varargin{2})
            fullFileName=varargin{2};
            [pathname,filename]=fileparts(fullFileName);
        else
            MLDATXFilter=getString(message('SDI:sdi:MLDATXFilter'));
            MLDATXDesc=getString(message('SDI:sdi:MLDATXDesc'));
            MLDATXSaveTitle=getString(message('SDI:sdi:MLDATXSaveTitle'));
            [filename,pathname]=uiputfile(...
            {MLDATXFilter,MLDATXDesc},MLDATXSaveTitle,ctrlObj.DefaultName);
            if isequal(filename,0)||isequal(pathname,0)
                return;
            end
        end


        thumbnailURL='';
        if nargin>2
            thumbnailURL=varargin{3};
        end


        fullFileName=fullfile(pathname,filename);
        if~isempty(thumbnailURL)
            Simulink.sdi.saveView(fullFileName,struct(),'sdi',thumbnailURL);
        else
            Simulink.sdi.saveView(fullFileName);
        end
    end
end
