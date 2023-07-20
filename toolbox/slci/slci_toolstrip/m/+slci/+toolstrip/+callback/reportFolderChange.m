


function reportFolderChange(cbinfo)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');
    ctx.setReportFolder(cbinfo.EventData);

end