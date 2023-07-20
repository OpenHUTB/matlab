function dlgStruct=variantConfigurationsDDG(h,name)








    isStandalone=true;
    srcCache=slvariants.internal.manager.ui.config.VariantConfigurationsCacheWrapper(isStandalone,h);

    configurationsDlgCreator=slvariants.internal.manager.ui.config.ConfigurationsDialogSchema(srcCache,isStandalone,name);
    configurationsDlgStruct=configurationsDlgCreator.getDialogSchema();

    constraintsDlgCreator=slvariants.internal.manager.ui.config.ConstraintsDialogSchema(srcCache,isStandalone,name);
    constraintsDlgStruct=constraintsDlgCreator.getDialogSchema();


    descTxt.Name=DAStudio.message('Simulink:dialog:VariantConfigurationsDescription');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name='Simulink.VariantConfigurationData';
    descGrp.Type='panel';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    configurationsPanel.Name='ConfigsPanel';
    configurationsPanel.Type='panel';
    configurationsPanel.Items=configurationsDlgStruct.Items;
    configurationsPanel.Tag='configsGroupTag';
    configurationsPanel.LayoutGrid=[2,1];
    configurationsPanel.RowStretch=[0,1];
    configurationsPanel.RowSpan=[1,1];
    configurationsPanel.ColSpan=[1,1];


    constraintsPanel.Name='ConstraintsPanel';
    constraintsPanel.Type='panel';
    constraintsPanel.Items=constraintsDlgStruct.Items;
    constraintsPanel.Tag='constraintsGroupTag';
    constraintsPanel.LayoutGrid=[2,1];
    constraintsPanel.RowStretch=[0,1];
    constraintsPanel.RowSpan=[1,1];
    constraintsPanel.ColSpan=[1,1];


    configurationsTab.Name=slvariants.internal.manager.ui.config.VMgrConstants.Configurations;
    configurationsTab.Items={configurationsPanel};
    configurationsTab.Tag='configurationsTabTag';


    constraintsTab.Name=slvariants.internal.manager.ui.config.VMgrConstants.Constraints;
    constraintsTab.Items={constraintsPanel};
    constraintsTab.Tag='constraintsTabTag';


    tabWidget.Name='ConfigsConstraintsTabsWidget';
    tabWidget.Type='tab';
    tabWidget.Tag='configsConstraintsTabWidgetTag';
    tabWidget.Tabs={configurationsTab,constraintsTab};
    tabWidget.ActiveTab=0;
    tabWidget.LayoutGrid=[1,1];
    tabWidget.RowSpan=[2,2];
    tabWidget.ColSpan=[1,1];

    dlgStruct.DialogTitle=[class(h),': ',name];
    dlgStruct.DialogMode='Slim';
    dlgStruct.Items={descGrp,tabWidget};
    dlgStruct.PostApplyCallback='variantConfigurationsDDGCallback';
    dlgStruct.PostApplyArgs={srcCache,'%dialog',name};
    dlgStruct.HelpMethod='helpview';
    dlgStruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_variantconfiguration_type'};
    dlgStruct.Geometry=[100,100,600,1000];
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.DialogTag=getString(message('Simulink:VariantManagerUI:FrameDialogTag'));
end


