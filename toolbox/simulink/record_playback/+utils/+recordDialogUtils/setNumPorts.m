

function setNumPorts(dlg,tag,value)

    value=strtrim(value);

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{tag,value});

    if~dlg.isWidgetWithError(tag)
        dlg.clearWidgetDirtyFlag(tag);
    end
end

