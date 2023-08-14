function setUseEnumDataType(dlg,obj,paramName,paramVal)
    if paramVal
        useEnumerated='on';
    else
        useEnumerated='off';
    end
    obj.getBlock().UseEnumeratedDataType=useEnumerated;
    dlg.clearWidgetDirtyFlag(paramName);
    utils.enableEnumTypeChanged(dlg,obj,true);
end

