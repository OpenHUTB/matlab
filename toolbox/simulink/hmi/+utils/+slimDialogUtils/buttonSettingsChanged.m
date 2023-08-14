


function buttonSettingsChanged(dialog,obj)

    blockHandle=get(obj.blockObj,'handle');
    isCoreBlock=get_param(blockHandle,'isCoreWebBlock');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end


    Labeltext=strtrim(dialog.getWidgetValue('buttonText'));
    onValueText=strtrim(dialog.getWidgetValue('onValue'));


    onValue=str2double(onValueText);
    param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:PushButtonValue'));
    [success,errormsg]=utils.isValidNumber(onValue,param);
    if~success
        dialog.setWidgetWithError('onValue',...
        DAStudio.UI.Util.Error('onValue','Error',errormsg,[255,0,0,100]));
        return;
    else
        dialog.clearWidgetWithError('onValue');
    end

    if~strcmpi(isCoreBlock,'on')
        widget=utils.getWidget(mdl,obj.widgetId,obj.isLibWidget);
        if~isempty(widget)
            widget.Text=Labeltext;
            widget.OnValue=onValue;
        end
    else
        currentLabelText=get_param(blockHandle,'ButtonText');
        if~strcmp(currentLabelText,Labeltext)
            set_param(blockHandle,'ButtonText',Labeltext);
        end
        currentOnValueText=get_param(blockHandle,'OnValue');
        if~strcmp(currentOnValueText,onValueText)
            set_param(blockHandle,'OnValue',onValueText);
        end
    end


    set_param(mdl,'Dirty','on');



    paramDlgs=obj.getOpenDialogs(true);
    for j=1:length(paramDlgs)
        if~isequal(dialog,paramDlgs{j})
            utils.updateButtonSettings(paramDlgs{j},{Labeltext,onValueText});
        end
    end
    dialog.enableApplyButton(false,false);
    dialog.clearWidgetDirtyFlag('buttonText');
    dialog.clearWidgetDirtyFlag('onValue');
end
