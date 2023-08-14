


function updateReportFolder(cbinfo,action)

    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');

    action.text=ctx.getReportFolder();

end