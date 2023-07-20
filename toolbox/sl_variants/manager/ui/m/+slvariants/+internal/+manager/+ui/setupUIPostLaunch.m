function setupUIPostLaunch(modelHandle)









    modelName=getfullname(modelHandle);
    configsDlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=configsDlg.getSource;
    globalConfigSSWidget=configsDlg.getWidgetInterface('globalWSSSWidgetTag');
    globalConfigSSWidget.select(configSchema.GlobalConfigSSSrc.Children(1));



    slvariants.internal.manager.core.restoreDiagnosticViewer(modelHandle);
    slvariants.internal.manager.core.minimizeDiagnosticViewer(modelHandle);

    helpPIComp=slvariants.internal.manager.ui.config.getInToolHelpComp(modelHandle);
    helpPIComp.restore;
    helpPIComp.minimize;



    configComp=slvariants.internal.manager.ui.config.getConfigurationsComp(modelHandle);
    constrComp=slvariants.internal.manager.ui.config.getConstraintsComp(modelHandle);
    constrComp.restore;
    configComp.restore;

    vmStudioHandle=slvariants.internal.manager.core.getStudio(modelHandle);
    vmStudioHandle.setActiveComponent(configComp);
end


