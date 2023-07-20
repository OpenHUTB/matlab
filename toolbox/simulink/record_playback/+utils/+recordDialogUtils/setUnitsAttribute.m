function setUnitsAttribute(dlg,obj)
    value=dlg.getWidgetValue('CheckUnits');
    if isempty(value)
        return;
    end
    blockHandle=get(obj.blockObj,'handle');
    recordSettings=get_param(blockHandle,'FileSettings');
    recordSettings.excelSettings.units=value;

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{'FileSettings',recordSettings});

    dlg.clearWidgetDirtyFlag('CheckUnits');
end
