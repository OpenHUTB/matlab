



function generateCodeOnly(cbinfo)

    slci.toolstrip.util.generateCode(cbinfo,false,true);


    vm=slci.view.Manager.getInstance;
    vw=vm.getView(cbinfo.studio);
    cv=vw.getCodeView();
    cv.refresh();
end