function setEnumDataType(dlg,obj,paramName,paramVal)
    obj.getBlock().EnumeratedDataType=paramVal;
    dlg.clearWidgetDirtyFlag(paramName);
    utils.updateDiscreteStates(obj.getBlock().Handle,obj.widgetId,true);
end

