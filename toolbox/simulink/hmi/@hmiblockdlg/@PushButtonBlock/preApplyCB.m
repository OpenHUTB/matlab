

function[success,errormsg]=preApplyCB(obj,dlg)

    success=true;
    errormsg='';

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end

    Labeltext=strtrim(dlg.getWidgetValue('buttonText'));
    onValueText=strtrim(dlg.getWidgetValue('onValue'));
    buttonType=dlg.getWidgetValue('buttonType');
    iconAlignment=dlg.getWidgetValue('iconAlignment');
    customizeIconColor=dlg.getWidgetValue('customizeIconColor');
    backgroundcolor=obj.BackgroundColor;
    foregroundcolor=obj.ForegroundColor;
    icon=obj.Icon;
    customIcon=obj.CustomIcon;
    iconOnColor=obj.IconOnColor;
    iconOffColor=obj.IconOffColor;


    onValue=str2double(onValueText);
    param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:PushButtonValue'));
    [success,errormsg]=utils.isValidNumber(onValue,param);
    if~success
        return;
    end

    opacity=dlg.getWidgetValue('opacity');
    labelPosition=simulink.hmi.getLabelPosition(...
    dlg.getComboBoxText('labelPosition'));

    set_param(blockHandle,'ButtonText',Labeltext);
    set_param(blockHandle,'OnValue',onValueText);
    bindParameter(obj);
    set_param(blockHandle,'LabelPosition',labelPosition);
    set_param(blockHandle,'ButtonType',buttonType);
    set_param(blockHandle,'Icon',icon);
    set_param(blockHandle,'CustomIcon',customIcon);
    set_param(blockHandle,'IconAlignment',iconAlignment);
    set_param(blockHandle,'IconColor',double(customizeIconColor));
    set_param(blockHandle,'IconOnColor',iconOnColor);
    set_param(blockHandle,'IconOffColor',iconOffColor);
    set_param(blockHandle,'BackgroundColor',backgroundcolor);
    set_param(blockHandle,'ForegroundColor',foregroundcolor);
    set_param(blockHandle,'Opacity',opacity);


    set_param(mdl,'Dirty','on');



    scChannel='/hmi_push_button_colors_controller_/';
    paramDlgs=obj.getOpenDialogs(true);
    for j=1:length(paramDlgs)
        paramDlgs{j}.enableApplyButton(false,false);

        if~isequal(dlg,paramDlgs{j})
            utils.updateButtonSettings(paramDlgs{j},{Labeltext,onValueText});
            utils.updateLabelPosition(paramDlgs{j},labelPosition);
            utils.updateOpacity(paramDlgs{j},opacity);
            message.publish([scChannel,'updateColors'],...
            {false,obj.widgetId,mdl,backgroundcolor,foregroundcolor});
        end
    end
end
