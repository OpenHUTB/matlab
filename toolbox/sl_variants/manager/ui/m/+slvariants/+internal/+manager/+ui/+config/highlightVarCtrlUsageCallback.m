function highlightVarCtrlUsageCallback(modelName,rowIdxs,isShowUsage)









    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource();
    ctrlVarRows=configSchema.CtrlVarSSSrc.Children(rowIdxs);
    len=length(ctrlVarRows);
    dataSourceVec=strings(1,len);
    for i=1:len
        dataSourceVec(i)=getPropValue(ctrlVarRows(i),slvariants.internal.manager.ui.config.VMgrConstants.Source);
    end
    isHighlighted=[ctrlVarRows(:).IsHighlighted];



    if(isShowUsage&&all(isHighlighted))
        return;
    end
    ctrlVarNames=configSchema.CtrlVarSSSrc.getControlVariableNames();
    ctrlVars=ctrlVarNames(rowIdxs);

    slvariants.internal.manager.core.highlightVariantControlUsage(get_param(modelName,'Handle'),ctrlVars,dataSourceVec,isShowUsage);
    for row=ctrlVarRows
        row.IsHighlighted=isShowUsage;
    end
    slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.callUpdateOnSpreadsheet(dlg,'controlVariablesSSWidgetTag');


    modelHandle=get_param(modelName,'Handle');
    slvariants.internal.manager.ui.config.setEnableForNavButtonVarUsage(modelHandle);


    studio=slvariants.internal.manager.core.getStudio(modelHandle);
    ssModelHier=studio.getComponent('GLUE2:SpreadSheet',message('Simulink:VariantManagerUI:HierarchyTitleVariant').getString());
    hierSSIdx=slvariants.internal.manager.ui.utils.getHierSSIndices();
    if configSchema.IsCompBrowserVisible&&(ssModelHier.getCurrentTab==hierSSIdx.ComponentConfigurations)


        ssModelHier.setCurrentTab(hierSSIdx.System);
    end
end


