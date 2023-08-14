function customizeAddCallBack(this)



    editHint=getString(message('Simulink:CustomCode:DeterministicFunctionsDlgSSFcnNameEditHint'));
    this.fcnSettingsSS.addNewChildren(editHint);
    this.enableApplyOnParentUponApply=true;
end
