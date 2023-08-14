function setInterpolationAttribute(dlg,obj)
    value=dlg.getWidgetValue('CheckInterpolation');
    if isempty(value)
        return;
    end
    blockHandle=get(obj.blockObj,'handle');
    recordSettings=get_param(blockHandle,'FileSettings');
    recordSettings.excelSettings.interpolation=value;

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{'FileSettings',recordSettings});

    dlg.clearWidgetDirtyFlag('CheckInterpolation');
end
