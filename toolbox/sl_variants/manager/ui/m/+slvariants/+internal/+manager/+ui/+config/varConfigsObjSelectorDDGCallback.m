function varargout=varConfigsObjSelectorDDGCallback(obj,dlg)




    import slvariants.internal.manager.ui.config.ConfigurationsDialogSchema;
    import slvariants.internal.manager.ui.config.ConstraintsDialogSchema;

    varargout={};
    selectedConfigObjectIdx=dlg.getWidgetValue('configRadioButtonWidgetTag')+1;
    obj.SelectedConfigObjectIdx=selectedConfigObjectIdx;
    obj.ConfigurationsDialogSchema.ConfigCatalogCacheWrapper.setVariantConfigurationCatalog(obj.VariantConfigObjects{selectedConfigObjectIdx});
    sourceCacheObj=obj.ConfigurationsDialogSchema.ConfigCatalogCacheWrapper;
    isStandalone=false;
    bdHandle=obj.ConfigurationsDialogSchema.BDHandle;
    mdlName=obj.ConfigurationsDialogSchema.BDName;

    newConfigSrc=ConfigurationsDialogSchema(sourceCacheObj,isStandalone,bdHandle);
    obj.VariantConfigurationsDialog.setSource(newConfigSrc);

    newConstrSrc=ConstraintsDialogSchema(sourceCacheObj,isStandalone,bdHandle);
    constrDlg=slvariants.internal.manager.ui.config.getConstraintsDialog(mdlName);
    constrDlg.setSource(newConstrSrc);



    configSchema=obj.VariantConfigurationsDialog.getSource;
    configSchema.updateVariantConfigurationsName(obj.VariantConfigObjectNames{selectedConfigObjectIdx},configSchema);

    vmStudioHandle=slvariants.internal.manager.core.getStudio(get_param(mdlName,'Handle'));
    vMgrToolStrip=vmStudioHandle.getToolStrip;
    as=vMgrToolStrip.getActionService();
    as.refreshAction('variantConfigsObjectNameEditBoxAction');

    varargout{1}=true;
    varargout{2}='';
end


