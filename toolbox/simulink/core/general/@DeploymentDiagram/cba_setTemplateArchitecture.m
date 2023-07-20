function cba_setTemplateArchitecture(modelName)




    me=DeploymentDiagram.explorer(modelName);
    if isempty(me)
        return;
    end
    dialogObj=Simulink.DistributedTarget.dialogSetTemplateArchitecture(me);
    me.archSelectDialog=DAStudio.Dialog(dialogObj);

    DeploymentDiagram.firePropertyChange(me.getRoot);
