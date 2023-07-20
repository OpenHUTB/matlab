function setCheckboxStateValue(dlg,obj,tag,idx,value)

    states=obj.getBlock().Values;
    states(idx)=str2double(value);

    param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:SwitchValue'));
    [success,msg]=utils.isValidNumber(states(idx),param);
    if~success
        dlg.setWidgetWithError(tag,...
        DAStudio.UI.Util.Error(tag,'Error',msg,[255,0,0,100]));
    else
        obj.getBlock().Values=states;
        dlg.clearWidgetWithError(tag);
        dlg.clearWidgetDirtyFlag(tag);
        hBlk=get(obj.getBlock(),'handle');
        model=get_param(bdroot(hBlk),'Name');
        set_param(model,'Dirty','on');
    end
end