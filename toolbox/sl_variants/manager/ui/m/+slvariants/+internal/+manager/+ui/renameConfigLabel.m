function renameConfigLabel(configSchema,value)






    if configSchema.IsStandalone
        dlgName=['Simulink.VariantConfigurationData: ',configSchema.ConfigObjVarName];
        dlg=findDDGByTitle(dlgName);



        if isempty(dlg)


            return;
        end


        dlg.setWidgetValue('configNameLabelTag',value);

        configSchema.setSelectedConfigName(value);

        dlg.refreshWidget('prefConfigComboboxTag');
    else
        modelName=configSchema.BDName;
        dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);

        dlg.setWidgetValue('configNameLabelTag',value);

        configSchema.setSelectedConfigName(value);

        dlg.refresh;
    end

end
