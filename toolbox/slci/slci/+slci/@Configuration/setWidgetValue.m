function setWidgetValue(aObj,widget,value)





    if isempty(aObj.fDialogHandle)
        prop=['f',widget];
        aObj.(prop)=value;
    else
        dlg=aObj.fDialogHandle;
        widgetId=aObj.getWidgetId(widget);
        if dlg.isWidgetValid(widgetId)
            dlg.setWidgetValue(widgetId,value);
        else
            DAStudio.error('Slci:ui:InvalidWidget',widget)
        end
    end
end
