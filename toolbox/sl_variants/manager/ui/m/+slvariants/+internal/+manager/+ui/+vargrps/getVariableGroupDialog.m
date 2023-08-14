function dlg=getVariableGroupDialog(modelName)




    vmStudioHandle=slvariants.internal.manager.core.getStudio(get_param(modelName,'Handle'));
    varGroupComp=vmStudioHandle.getComponent('GLUE2:DDG Component',message('Simulink:VariantManagerUI:VariableGroupsTabTitle').getString());
    dlg=varGroupComp.getDialog();
end
