function setEnableGenerateConfigsButton(cbinfo,action)




    modelHandle=cbinfo.Context.Object.App.ModelHandle;
    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    ddgComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:AutoGenConfigureControlVariablesDDG').getString());
    if isempty(ddgComp)
        return;
    end

    dlg=ddgComp.getDialog;
    action.enabled=dlg.getSource().getConfigCtrlVariablesSource().canGenerateButtonEnabled();
end
