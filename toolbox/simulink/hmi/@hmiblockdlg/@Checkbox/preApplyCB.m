
function[success,errormsg]=preApplyCB(obj,dlg)
    success=true;
    errormsg='';

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end
    foregroundColor=obj.ForegroundColor;
    backgroundColor=obj.BackgroundColor;
    uncheckedValue=str2double(strtrim(dlg.getWidgetValue('uncheckedValue')));
    checkedValue=str2double(strtrim(dlg.getWidgetValue('checkedValue')));
    label=strtrim(dlg.getWidgetValue('labelField'));

    labelPosition=simulink.hmi.getLabelPosition(...
    dlg.getComboBoxText('labelPosition'));

    param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:SwitchValue'));
    [success,errormsg]=utils.isValidNumber(uncheckedValue,param);
    if~success
        return;
    end

    param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:SwitchValue'));
    [success,errormsg]=utils.isValidNumber(checkedValue,param);
    if~success
        return;
    end

    opacity=dlg.getWidgetValue('opacity');

    bindParameter(obj);
    set_param(blockHandle,'LabelPosition',labelPosition);
    set_param(blockHandle,'Values',[uncheckedValue,checkedValue]);
    set_param(blockHandle,'Label',label);
    set_param(blockHandle,'ForegroundColor',foregroundColor);
    set_param(blockHandle,'BackgroundColor',backgroundColor);
    set_param(blockHandle,'Opacity',opacity);
    set_param(mdl,'Dirty','on');
    paramDlgs=obj.getOpenDialogs(true);
    for idx=1:length(paramDlgs)
        utils.updateOpacity(paramDlgs{idx},opacity);
        paramDlgs{idx}.enableApplyButton(false,false);
    end
end
