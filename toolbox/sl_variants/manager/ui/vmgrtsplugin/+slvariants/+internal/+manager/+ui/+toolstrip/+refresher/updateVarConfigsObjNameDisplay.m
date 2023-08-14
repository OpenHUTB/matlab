function updateVarConfigsObjNameDisplay(cbinfo,action)




    bdHandle=cbinfo.Context.Object.getModelHandle();
    modelName=getfullname(bdHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;
    cbinfo.Context.Object.setVarConfigsObjName(configSchema.ConfigObjVarName);



    cbinfo.Context.Object.TempVarConfigsObjName=cbinfo.Context.Object.VarConfigsObjName;

    if~action.text.isequal(cbinfo.Context.Object.VarConfigsObjName)
        if isempty(cbinfo.Context.Object.VarConfigsObjName)
            action.text="";
            return;
        end
        action.text=cbinfo.Context.Object.VarConfigsObjName;
    end
end
