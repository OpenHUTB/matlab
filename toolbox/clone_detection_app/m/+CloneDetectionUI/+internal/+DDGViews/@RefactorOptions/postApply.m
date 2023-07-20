function[status]=postApply(this)

    status=true;

    annotations=this.fDialogHandle.getComboBoxText('annotationsComboTag');
    storageClasses=this.fDialogHandle.getComboBoxText('storageClassesComboTag');
    dialogParam=this.fDialogHandle.getComboBoxText('dialogParamTag');
    triggerPlot=this.fDialogHandle.getComboBoxText('triggerPlotTag');
    machineParentData=this.fDialogHandle.getComboBoxText('machineParentDataTag');
    simulinkFunction=this.fDialogHandle.getComboBoxText('simulinkFunctionTag');
    subsystemPermissions=this.fDialogHandle.getComboBoxText('subsystemPermissionsTag');

    this.cloneUIthis.refactorOptions={annotations,storageClasses,dialogParam,triggerPlot,...
    machineParentData,simulinkFunction,subsystemPermissions};
    this.fDialogHandle.setTitle(this.title);
    this.setUnsavedChanges(false);
    this.fDialogHandle.refresh;


    CloneDetectionUI.internal.util.saveCloneDetectionUIthisToLatestVersion(this.model);
end

