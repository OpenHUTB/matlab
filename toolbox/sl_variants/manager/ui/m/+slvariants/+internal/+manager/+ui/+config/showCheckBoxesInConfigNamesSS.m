function showCheckBoxesInConfigNamesSS(modelHandle)






    import slvariants.internal.manager.ui.config.ReduceAnalyzeModes;

    modelName=getfullname(modelHandle);
    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configDlgSchema=dlg.getSource;

    if configDlgSchema.ReduceAnalyzeModeFlag<3
        return;
    end

    ssComp=dlg.getWidgetInterface('configsSSWidgetTag');

    if~isempty(ssComp)

        ssComp.addColumn(slvariants.internal.manager.ui.config.VMgrConstants.SelectCol,'Name','before');
    end

    dlg.refresh();
    dlg.setEnabled('convertTypesSplitButtonTag',false);
end


