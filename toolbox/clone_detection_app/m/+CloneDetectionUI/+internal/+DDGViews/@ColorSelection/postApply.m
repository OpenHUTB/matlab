function[status]=postApply(this)

    status=true;

    this.cloneUIObj.colorCodes.exactColor=this.fDialogHandle.getComboBoxText('exactColorComboTag');
    this.cloneUIObj.colorCodes.similarColor=this.fDialogHandle.getComboBoxText('similarColorComboTag');
    this.cloneUIObj.colorCodes.exclusionColor=this.fDialogHandle.getComboBoxText('excludedColorComboTag');

    this.fDialogHandle.setTitle(this.title);
    this.setUnsavedChanges(false);
    this.fDialogHandle.refresh;


    CloneDetectionUI.internal.util.saveCloneDetectionUIthisToLatestVersion(this.model);
end

