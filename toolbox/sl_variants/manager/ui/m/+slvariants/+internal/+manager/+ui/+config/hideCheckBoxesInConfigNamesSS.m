function hideCheckBoxesInConfigNamesSS(modelHandle)






    import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configDlgSchema=dlg.getSource;

    if configDlgSchema.ReduceAnalyzeModeFlag>2
        return;
    end

    ssComp=dlg.getWidgetInterface('configsSSWidgetTag');

    if~isempty(ssComp)

        ssComp.removeColumn(slvariants.internal.manager.ui.config.VMgrConstants.SelectCol);
    end

    dlg.refresh();
    dlg.setEnabled('convertTypesSplitButtonTag',false);
end


