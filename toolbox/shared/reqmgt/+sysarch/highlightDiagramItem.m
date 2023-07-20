function highlightDiagramItem(model,diagramItem)


    bdH=get_param(model,'Handle');
    sysarchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);
    edController=sysarchApp.getCurrentEditor;
    edController.highlightDiagramItem(diagramItem.UUID);
end