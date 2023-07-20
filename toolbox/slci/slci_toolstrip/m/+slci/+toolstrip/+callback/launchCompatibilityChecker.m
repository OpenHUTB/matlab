


function launchCompatibilityChecker(cbinfo)
    ctx=cbinfo.studio.App.getAppContextManager.getCustomContext('slciApp');
    if ctx.getCompatibilityOn()


        return;
    end
    ctx.setCompatibilityOn(true);

    try

        slci.Configuration.checkWorkDir;


        configObj=slci.toolstrip.util.getConfiguration(cbinfo.studio);


        configObj.CheckCompatibilityTSCB();
    catch ME
        ctx.setCompatibilityOn(false);
        slci.internal.outputMessage(ME,'error');
        return;
    end

    ctx.setCompatibilityOn(false);


    ctx.setModelAdvisorReportFolder(configObj.getModelAdvisorReportFolder());


    vm=slci.view.Manager.getInstance;
    vw=vm.getView(cbinfo.studio);
    rp=vw.getCompatibility();
    rp.refresh();
    rp.show();

end