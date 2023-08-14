

function success=onRadioSelectionChange(this,dropDownValue,bindableType,bindableName,bindableMetaData,isChecked)


    success=utils.HMIBindMode.onRadioSelectionChange(this.sourceElementHandle,dropDownValue,bindableType,...
    bindableName,bindableMetaData,isChecked);
end