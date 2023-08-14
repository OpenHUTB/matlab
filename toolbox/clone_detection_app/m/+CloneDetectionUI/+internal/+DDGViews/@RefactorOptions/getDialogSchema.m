function dlgStruct=getDialogSchema(obj)

    annotationsLabel.Type='text';
    annotationsLabel.Tag='annotationsLabelTag';
    annotationsLabel.Name=DAStudio.message('sl_pir_cpp:creator:annotationsLabelName');
    annotationsLabel.RowSpan=[1,1];
    annotationsLabel.ColSpan=[1,1];

    annotationsCombo.Name='';
    annotationsCombo.Type='combobox';
    annotationsCombo.RowSpan=[1,1];
    annotationsCombo.ColSpan=[2,2];
    annotationsCombo.Value=obj.cloneUIObj.refactorOptions{1};
    annotationsCombo.Mode=1;
    annotationsCombo.Entries={DAStudio.message('sl_pir_cpp:creator:Include'),...
    DAStudio.message('sl_pir_cpp:creator:Exclude')};
    annotationsCombo.Tag='annotationsComboTag';
    annotationsCombo.ObjectMethod='dirtyEditor';

    storageClassesLabel.Type='text';
    storageClassesLabel.Tag='storageClassesLabelTag';
    storageClassesLabel.Name=DAStudio.message('sl_pir_cpp:creator:storageClassesLabelName');
    storageClassesLabel.RowSpan=[2,2];
    storageClassesLabel.ColSpan=[1,1];

    storageClassesCombo.Name='';
    storageClassesCombo.Type='combobox';
    storageClassesCombo.RowSpan=[2,2];
    storageClassesCombo.ColSpan=[2,2];
    storageClassesCombo.Value=obj.cloneUIObj.refactorOptions{2};
    storageClassesCombo.Mode=1;
    storageClassesCombo.Entries={DAStudio.message('sl_pir_cpp:creator:Include'),...
    DAStudio.message('sl_pir_cpp:creator:Exclude')};
    storageClassesCombo.Tag='storageClassesComboTag';
    storageClassesCombo.ObjectMethod='dirtyEditor';

    dialogParamLabel.Type='text';
    dialogParamLabel.Tag='dialogParamLabelTag';
    dialogParamLabel.Name=DAStudio.message('sl_pir_cpp:creator:dialogParamLabelName');
    dialogParamLabel.RowSpan=[3,3];
    dialogParamLabel.ColSpan=[1,1];

    dialogParam.Name='';
    dialogParam.Type='combobox';
    dialogParam.RowSpan=[3,3];
    dialogParam.ColSpan=[2,2];
    dialogParam.Value=obj.cloneUIObj.refactorOptions{3};
    dialogParam.Mode=1;
    dialogParam.Entries={DAStudio.message('sl_pir_cpp:creator:Include'),DAStudio.message('sl_pir_cpp:creator:Exclude')};
    dialogParam.Tag='dialogParamTag';
    dialogParam.ObjectMethod='dirtyEditor';

    triggerPlotLabel.Type='text';
    triggerPlotLabel.Tag='triggerPlotLabelTag';
    triggerPlotLabel.Name=DAStudio.message('sl_pir_cpp:creator:triggerPlotLabelName');
    triggerPlotLabel.RowSpan=[4,4];
    triggerPlotLabel.ColSpan=[1,1];

    triggerPlot.Name='';
    triggerPlot.Type='combobox';
    triggerPlot.RowSpan=[4,4];
    triggerPlot.ColSpan=[2,2];
    triggerPlot.Value=obj.cloneUIObj.refactorOptions{4};
    triggerPlot.Mode=1;
    triggerPlot.Entries={DAStudio.message('sl_pir_cpp:creator:Include'),...
    DAStudio.message('sl_pir_cpp:creator:Exclude')};
    triggerPlot.Tag='triggerPlotTag';
    triggerPlot.ObjectMethod='dirtyEditor';

    machineParentLabel.Type='text';
    machineParentLabel.Tag='machineParentLabelTag';
    machineParentLabel.Name=DAStudio.message('sl_pir_cpp:creator:machineParentLabelName');
    machineParentLabel.RowSpan=[5,5];
    machineParentLabel.ColSpan=[1,1];

    machineParentData.Name='';
    machineParentData.Type='combobox';
    machineParentData.RowSpan=[5,5];
    machineParentData.ColSpan=[2,2];
    machineParentData.Value=obj.cloneUIObj.refactorOptions{5};
    machineParentData.Mode=1;
    machineParentData.Entries={DAStudio.message('sl_pir_cpp:creator:Include'),...
    DAStudio.message('sl_pir_cpp:creator:Exclude')};
    machineParentData.Tag='machineParentDataTag';
    machineParentData.ObjectMethod='dirtyEditor';

    simulinkFunctionLabel.Type='text';
    simulinkFunctionLabel.Tag='simulinkFunctionLabelTag';
    simulinkFunctionLabel.Name=DAStudio.message('sl_pir_cpp:creator:simulinkFunctionLabelName');
    simulinkFunctionLabel.RowSpan=[6,6];
    simulinkFunctionLabel.ColSpan=[1,1];

    simulinkFunction.Name='';
    simulinkFunction.Type='combobox';
    simulinkFunction.RowSpan=[6,6];
    simulinkFunction.ColSpan=[2,2];
    simulinkFunction.Value=obj.cloneUIObj.refactorOptions{6};
    simulinkFunction.Mode=1;
    simulinkFunction.Entries={DAStudio.message('sl_pir_cpp:creator:Include'),...
    DAStudio.message('sl_pir_cpp:creator:Exclude')};
    simulinkFunction.Tag='simulinkFunctionTag';
    simulinkFunction.ObjectMethod='dirtyEditor';

    subsystemPermissionsLabel.Type='text';
    subsystemPermissionsLabel.Tag='subsystemPermissionsLabelTag';
    subsystemPermissionsLabel.Name=DAStudio.message('sl_pir_cpp:creator:subsystemPermissionsLabelName');
    subsystemPermissionsLabel.RowSpan=[7,7];
    subsystemPermissionsLabel.ColSpan=[1,1];

    subsystemPermissions.Name='';
    subsystemPermissions.Type='combobox';
    subsystemPermissions.RowSpan=[7,7];
    subsystemPermissions.ColSpan=[2,2];
    subsystemPermissions.Value=obj.cloneUIObj.refactorOptions{7};
    subsystemPermissions.Mode=1;
    subsystemPermissions.Entries={DAStudio.message('sl_pir_cpp:creator:Include'),...
    DAStudio.message('sl_pir_cpp:creator:Exclude')};
    subsystemPermissions.Tag='subsystemPermissionsTag';
    subsystemPermissions.ObjectMethod='dirtyEditor';

    groupColorSettings.Type='group';
    groupColorSettings.Name='';
    groupColorSettings.LayoutGrid=[7,3];
    groupColorSettings.Flat=true;
    groupColorSettings.Items={annotationsLabel,annotationsCombo,storageClassesLabel,storageClassesCombo,...
    dialogParamLabel,dialogParam,triggerPlotLabel,triggerPlot,machineParentData,machineParentLabel,...
    simulinkFunctionLabel,subsystemPermissions,subsystemPermissionsLabel,simulinkFunction};

    dlgStruct.DialogTitle=obj.title;
    dlgStruct.DialogTag='RefactorOptions';
    dlgStruct.Items={groupColorSettings};
    dlgStruct.LayoutGrid=[7,2];
    dlgStruct.DisplayIcon=fullfile(matlabroot,'toolbox','clone_detection_app','m','ui',...
    'images','detect_16.png');
    dlgStruct.PostApplyMethod='postApply';
end
