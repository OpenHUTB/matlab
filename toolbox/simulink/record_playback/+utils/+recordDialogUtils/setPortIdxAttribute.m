function setPortIdxAttribute(dlg,obj)
    value=dlg.getWidgetValue('CheckPortIdx');
    if isempty(value)
        return;
    end
    blockHandle=get(obj.blockObj,'handle');
    recordSettings=get_param(blockHandle,'FileSettings');
    recordSettings.excelSettings.portIndex=value;

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{'FileSettings',recordSettings});

    dlg.clearWidgetDirtyFlag('CheckPortIdx');
end
