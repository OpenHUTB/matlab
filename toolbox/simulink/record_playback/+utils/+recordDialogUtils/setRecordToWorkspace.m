


function setRecordToWorkspace(dlg,tag,value)
    if value
        value='1';
    else
        value='0';
    end

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{tag,value});

    dlg.clearWidgetDirtyFlag('RecordToWorkspace');
end
