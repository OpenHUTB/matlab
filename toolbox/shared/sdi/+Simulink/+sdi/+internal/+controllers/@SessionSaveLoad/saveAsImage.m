function saveAsImage(varargin)



    [appName,varargin]=Simulink.sdi.internal.controllers.SessionSaveLoad.parseAppName(varargin{:});
    ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
    if ctrlObj.ActionInProgress
        beep;
    else
        tmp=onCleanup(@()updateGUITitle(ctrlObj));
        ctrlObj.ActionInProgress=true;
        tmp2=onCleanup(@()Simulink.sdi.internal.controllers.SessionSaveLoad.setActionInProgress(appName,false));
        imgFilter=getString(message('SDI:sdi:PNGFilter'));
        imgDesc=getString(message('SDI:sdi:PNGDesc'));
        imgSaveTitle=getString(message('SDI:sdi:PNGSaveTitle'));
        [filename,pathname]=uiputfile(...
        {imgFilter,imgDesc},imgSaveTitle,ctrlObj.DefaultName);
        if isequal(filename,0)||isequal(pathname,0)
            return;
        end

        fullFileName=fullfile(pathname,filename);
        if nargin>1
            thumbnailURL=varargin{2};
        end
        if~isempty(thumbnailURL)
            Simulink.sdi.saveImage(appName,fullFileName,thumbnailURL);
        else
            Simulink.sdi.saveImage(appName,fullFileName);
        end
    end
end