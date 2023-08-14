



function generateCode(cbinfo)

    try

        slci.Configuration.checkWorkDir;
        slci.toolstrip.util.generateCode(cbinfo,true);
    catch ME
        slci.internal.outputMessage(ME,'error');
        return;
    end


    vm=slci.view.Manager.getInstance;
    vw=vm.getView(cbinfo.studio);
    cv=vw.getCodeView();
    cv.refresh();

end