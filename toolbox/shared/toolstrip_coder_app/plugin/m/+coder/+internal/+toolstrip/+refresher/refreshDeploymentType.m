function refreshDeploymentType(cbinfo,action)



    if slfeature('SDPToolStrip',1)==0
        return;
    end

    h=cbinfo.editorModel.handle;
    type=coder.internal.toolstrip.util.getDeploymentTypeContext(h);

    studio=cbinfo.studio;
    contextManager=studio.App.getAppContextManager;
    customContext=contextManager.getCustomContext('embeddedCoderApp');
    if~isempty(customContext)
        customContext.DeployContext=type;
        customContext.refreshContext();
    end