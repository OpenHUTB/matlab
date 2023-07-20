


function launchInspect(cbinfo)












    try

        slci.Configuration.checkWorkDir;


        configObj=slci.toolstrip.util.getConfiguration(cbinfo.studio);

    catch ME
        slci.internal.outputMessage(ME,'error');
        return;
    end


    out=configObj.InspectTSCB();

    if~out

        return;
    end


    vm=slci.view.Manager.getInstance;
    vw=vm.getView(cbinfo.studio);
    rp=vw.getReport();
    rp.refresh();


    dv=vw.getResultReview();
    dv.refresh();
    dv.show();
end