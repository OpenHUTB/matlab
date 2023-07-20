function PeripheralWidget=getPeripheralWidgetFor(hView,WidgetHint,peripheralIdx,widgetIdx)





    PeripheralWidget.Name=WidgetHint.Name;
    PeripheralWidget.Tag=WidgetHint.Tag;
    PeripheralWidget.Type=WidgetHint.Type;
    if(strcmp(WidgetHint.Type,'pushbutton'))
        value=' ';
    else
        value='%value';
        PeripheralWidget.Entries=WidgetHint.Entries;
        if(numel(PeripheralWidget.Entries)>1)
            PeripheralWidget.Value=hView.getMatchIdx(WidgetHint.Entries,WidgetHint.Value);
        else
            PeripheralWidget.Value=WidgetHint.Value;
        end
    end
    PeripheralWidget.Enabled=WidgetHint.Enabled;
    PeripheralWidget.Visible=WidgetHint.Visible;
    PeripheralWidget.RowSpan=WidgetHint.RowSpan;
    PeripheralWidget.ColSpan=WidgetHint.ColSpan;
    PeripheralWidget=hView.addControllerCallBack(PeripheralWidget,'handlePeripheral',value,peripheralIdx,widgetIdx);
