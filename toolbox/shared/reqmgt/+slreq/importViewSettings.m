











function importViewSettings(viewSettingFile,overwriteExisting)

    if nargin<2
        overwriteExisting=false;
    end
    vsm=slreq.app.MainManager.getInstance.getViewSettingsManager;
    vsm.importViewSettings(viewSettingFile,overwriteExisting);
end