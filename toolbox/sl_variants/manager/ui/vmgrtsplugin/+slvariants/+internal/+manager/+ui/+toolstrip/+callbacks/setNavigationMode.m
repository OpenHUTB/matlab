function setNavigationMode(cbinfo)



    navInfo=cbinfo.EventData;
    cbinfo.Context.Object.setNavigationInfo(navInfo);


    modelHandle=cbinfo.Context.Object.getModelHandle();
    studio=slvariants.internal.manager.core.getStudio(modelHandle);


    toolStrip=studio.getToolStrip;


    as=toolStrip.getActionService();
    as.refreshAction('navigateLeftChoicesAction');
    as.refreshAction('navigateRightChoicesAction');
end


