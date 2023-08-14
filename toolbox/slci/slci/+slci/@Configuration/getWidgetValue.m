function out=getWidgetValue(aObj,widget)





    if isempty(aObj.fDialogHandle)
        prop=['f',widget];
        out=aObj.(prop);
    else
        dlg=aObj.fDialogHandle;
        widgetId=aObj.getWidgetId(widget);
        if dlg.isWidgetValid(widgetId)

            out=dlg.getComboBoxText(widgetId);
            if isempty(out)
                out=dlg.getWidgetValue(widgetId);
            end
        else
            DAStudio.error('Slci:ui:InvalidWidget',widget)
        end
    end
end
