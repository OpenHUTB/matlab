function setDataTypeAttribute(dlg,obj)
    value=dlg.getWidgetValue('CheckDataType');
    if isempty(value)
        return;
    end
    blockHandle=get(obj.blockObj,'handle');
    recordSettings=get_param(blockHandle,'FileSettings');
    recordSettings.excelSettings.dataType=value;

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{'FileSettings',recordSettings});

    dlg.clearWidgetDirtyFlag('CheckDataType');
end
