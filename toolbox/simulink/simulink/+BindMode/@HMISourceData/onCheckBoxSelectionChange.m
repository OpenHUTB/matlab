

function success=onCheckBoxSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)


    success=utils.HMIBindMode.onCheckBoxSelectionChange(this.sourceElementHandle,dropDownValue,bindableType,bindableName,...
    bindableMetaData,isChecked);
end