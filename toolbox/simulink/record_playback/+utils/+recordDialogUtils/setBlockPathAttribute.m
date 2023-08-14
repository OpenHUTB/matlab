function setBlockPathAttribute(dlg,obj)
    value=dlg.getWidgetValue('CheckBlockPath');
    if isempty(value)
        return;
    end
    blockHandle=get(obj.blockObj,'handle');
    recordSettings=get_param(blockHandle,'FileSettings');
    recordSettings.excelSettings.blockPath=value;

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{'FileSettings',recordSettings});

    dlg.clearWidgetDirtyFlag('CheckBlockPath');
end
