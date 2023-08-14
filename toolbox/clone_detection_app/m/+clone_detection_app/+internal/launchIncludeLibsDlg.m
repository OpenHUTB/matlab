function launchIncludeLibsDlg(cbinfo)

    sysHandle=SLStudio.Utils.getModelName(cbinfo);
    ui=get_param(sysHandle,'CloneDetectionUIObj');
    ui.ddgBottom.includeLibrariesCallback();

end