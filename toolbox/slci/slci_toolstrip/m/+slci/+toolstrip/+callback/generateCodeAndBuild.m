



function generateCodeAndBuild(cbinfo)

    slci.toolstrip.util.generateCode(cbinfo,false,false);


    vm=slci.view.Manager.getInstance;
    vw=vm.getView(cbinfo.studio);
    cv=vw.getCodeView();
    cv.refresh();
end