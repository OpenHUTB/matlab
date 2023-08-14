

function[success,errormsg]=preApplyCB(obj,dlg)

    success=true;
    errormsg='';

    SwitchStatesToUpdate={};

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end

    offLabel=strtrim(dlg.getWidgetValue('offLabel'));
    onLabel=strtrim(dlg.getWidgetValue('onLabel'));


    offValue=str2double(strtrim(dlg.getWidgetValue('offValue')));
    param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:SwitchValue'));
    [success,errormsg]=utils.isValidNumber(offValue,param);
    if~success
        return;
    end


    onValue=str2double(strtrim(dlg.getWidgetValue('onValue')));
    param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:SwitchValue'));
    [success,errormsg]=utils.isValidNumber(onValue,param);
    if~success
        return;
    end

    SwitchStatesToUpdate{1}=offLabel;
    SwitchStatesToUpdate{2}=num2str(offValue);
    SwitchStatesToUpdate{3}=onLabel;
    SwitchStatesToUpdate{4}=num2str(onValue);

    labelPosition=simulink.hmi.getLabelPosition(...
    dlg.getComboBoxText('labelPosition'));

    set_param(blockHandle,'LabelPosition',labelPosition);
    set_param(blockHandle,'Values',{{offLabel,onLabel},[offValue,onValue]});

    bindParameter(obj);


    set_param(mdl,'Dirty','on');



    paramDlgs=obj.getOpenDialogs(true);
    for j=1:length(paramDlgs)
        paramDlgs{j}.enableApplyButton(false,false);

        if~isequal(dlg,paramDlgs{j})
            utils.updateSwitchLabelValue(paramDlgs{j},SwitchStatesToUpdate);
            utils.updateLabelPosition(paramDlgs{j},labelPosition);
        end
    end
end
