function dlg=getConstraintsDialog(modelName)




    modelHandle=get_param(modelName,'Handle');
    constrsComp=slvariants.internal.manager.ui.config.getConstraintsComp(modelHandle);
    dlg=constrsComp.getDialog();
end
