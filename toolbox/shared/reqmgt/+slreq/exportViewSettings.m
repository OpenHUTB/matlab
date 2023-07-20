









function exportViewSettings(viewSettingFile)
    vsm=slreq.app.MainManager.getInstance.getViewSettingsManager;
    vsm.exportViewSettings(viewSettingFile);
end