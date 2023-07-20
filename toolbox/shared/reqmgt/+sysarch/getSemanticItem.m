function item=getSemanticItem(model,uuid)


    bdH=get_param(model,'Handle');
    sysarchApp=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(bdH);

    mfModel=sysarchApp.getArchitectureViewsManager.getModel;
    item=mfModel.findElement(uuid);
end