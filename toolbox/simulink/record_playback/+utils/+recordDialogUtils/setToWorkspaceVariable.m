


function setToWorkspaceVariable(dlg,tag,value)


    toWorkspaceValue=strtrim(value);

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{tag,toWorkspaceValue});

    if~dlg.isWidgetWithError(tag)
        dlg.clearWidgetDirtyFlag(tag);
    end
end
