


function setPortSelection(dlg,tag)
    value=dlg.getComboBoxText(tag);
    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{tag,value});
    dlg.clearWidgetDirtyFlag(tag);
end