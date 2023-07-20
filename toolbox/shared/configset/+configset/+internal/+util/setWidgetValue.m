function setWidgetValue(dlg,param,value)














    if ishandle(dlg)
        cs=dlg.getDialogSource.Source.Source;
        try
            set_param(cs,param,value);
        catch me

            errordlg(me.message);
            return
        end
        dlg.getDialogSource.enableApplyButton(true);
        dirtyWidget(ConfigSet.DDGWrapper(dlg),param,true);
    end
