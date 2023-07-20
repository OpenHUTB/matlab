function[dlgOk,errorMsg]=dataTypeAssistantPreApplyCallback(slimDlg,comboboxTag,dtaDlg,PropName)
















    value=dtaDlg.getWidgetValue(comboboxTag);
    DAStudio.delayedCallback(@applyCallbackDTA,slimDlg,PropName,value,comboboxTag);

    dlgOk=true;
    errorMsg='';

end
function applyCallbackDTA(slimDlg,PropName,value,comboboxTag)
    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',slimDlg,{PropName,value});
    slimDlg.setWidgetValue(comboboxTag,value)
    if~slimDlg.isWidgetWithError(comboboxTag)
        slimDlg.clearWidgetDirtyFlag(comboboxTag)
    end

end
