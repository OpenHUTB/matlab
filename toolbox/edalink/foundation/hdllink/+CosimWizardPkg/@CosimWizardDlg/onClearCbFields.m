function onClearCbFields(this,dlg)



    setWidgetValue(dlg,'edaSelectCbType',0);
    setWidgetValue(dlg,'edaCbHdlComponent','');
    setWidgetValue(dlg,'edaTriggerMode',0);
    this.TriggerMode=0;
    setWidgetValue(dlg,'edaCbSampleTime','');
    setWidgetValue(dlg,'edaTriggerSignal','');
    setWidgetValue(dlg,'edaCbFcnName','');
    dlg.apply;
end


