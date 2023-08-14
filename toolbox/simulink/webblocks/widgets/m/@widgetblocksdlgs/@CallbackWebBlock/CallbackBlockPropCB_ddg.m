function CallbackBlockPropCB_ddg(obj,dlg,h,tag,value)
    dlg.clearWidgetWithError(tag);
    roundedPressDelay=round(str2double(dlg.getWidgetValue('PressDelay')));
    roundedRepeatInterval=round(str2double(dlg.getWidgetValue('RepeatInterval')));
    if dlg.isEnabled('PressDelay')...
        &&(isnan(roundedPressDelay)||(str2double(dlg.getWidgetValue('PressDelay'))<0))
        dlg.setWidgetWithError('PressDelay',DAStudio.UI.Util.Error('PressDelay','Error',DAStudio.message('SimulinkHMI:dialogs:PressDelayError'),[255,0,0,100]));
        return;
    end
    if dlg.isEnabled('RepeatInterval')...
        &&(isnan(roundedRepeatInterval)||(str2double(dlg.getWidgetValue('RepeatInterval'))<0))
        dlg.setWidgetWithError('RepeatInterval',DAStudio.UI.Util.Error('RepeatInterval','Error',DAStudio.message('SimulinkHMI:dialogs:RepeatIntervalError'),[255,0,0,100]));
        return;
    end
    defaultBlockPropCB_ddg(dlg,h,tag,value);
end