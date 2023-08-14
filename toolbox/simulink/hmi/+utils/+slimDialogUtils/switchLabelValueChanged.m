

function switchLabelValueChanged(dialog,obj)

    SwitchStatesToUpdate={};

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end

    offStateLabel=strtrim(dialog.getWidgetValue('offLabel'));
    offStateValue=str2double(dialog.getWidgetValue('offValue'));
    onStateLabel=strtrim(dialog.getWidgetValue('onLabel'));
    onStateValue=str2double(dialog.getWidgetValue('onValue'));

    SwitchStatesToUpdate{1}=offStateLabel;
    SwitchStatesToUpdate{2}=num2str(offStateValue);
    SwitchStatesToUpdate{3}=onStateLabel;
    SwitchStatesToUpdate{4}=num2str(onStateValue);

    param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:SwitchValue'));
    [isValidOffValue,errormsg]=utils.isValidNumber(offStateValue,param);
    if~isValidOffValue
        dialog.setWidgetWithError('offValue',...
        DAStudio.UI.Util.Error('offValue','Error',errormsg,[255,0,0,100]));
    else
        dialog.clearWidgetWithError('offValue');
    end

    [isValidOnValue,errormsg]=utils.isValidNumber(onStateValue,param);
    if~isValidOnValue
        dialog.setWidgetWithError('onValue',...
        DAStudio.UI.Util.Error('onValue','Error',errormsg,[255,0,0,100]));
    else
        dialog.clearWidgetWithError('onValue');
    end

    if~isValidOnValue||~isValidOffValue
        return;
    end

    set_param(blockHandle,'Values',...
    {{offStateLabel,onStateLabel},[offStateValue,onStateValue]});


    set_param(mdl,'Dirty','on');


    paramDlgs=obj.getOpenDialogs(true);
    for j=1:length(paramDlgs)
        if~isequal(dialog,paramDlgs{j})
            utils.updateSwitchLabelValue(paramDlgs{j},SwitchStatesToUpdate);
        end
    end
    dialog.enableApplyButton(false,false);

    dialog.clearWidgetDirtyFlag('offLabel');
    dialog.clearWidgetDirtyFlag('offValue');
    dialog.clearWidgetDirtyFlag('onLabel');
    dialog.clearWidgetDirtyFlag('onValue');
end
