function[success,errormsg]=preApplyCB(obj,dlg)

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    success=true;
    errormsg='';
    if Simulink.HMI.isLibrary(mdl)
        return;
    end

    newTextAlign=simulink.hmi.getDisplayBlockAlignment(...
    dlg.getComboBoxText('textAlign'));
    labelPosition=simulink.hmi.getLabelPosition(...
    dlg.getComboBoxText('labelPosition'));

    backgroundcolor=obj.BackgroundColor;
    foregroundcolor=obj.ForegroundColor;
    opacity=dlg.getWidgetValue('opacity');

    bindParameter(obj);
    set_param(blockHandle,'Alignment',newTextAlign);
    set_param(blockHandle,'LabelPosition',labelPosition);
    set_param(blockHandle,'BackgroundColor',backgroundcolor);
    set_param(blockHandle,'ForegroundColor',foregroundcolor);
    set_param(blockHandle,'Opacity',opacity);
    set_param(mdl,'Dirty','on');



    scChannel='/hmi_editfield_colors_controller_/';
    paramDlgs=obj.getOpenDialogs(true);
    for idx=1:length(paramDlgs)
        paramDlgs{idx}.enableApplyButton(false,false);

        if~isequal(dlg,paramDlgs{idx})
            message.publish([scChannel,'updateColors'],...
            {false,obj.widgetId,mdl,backgroundcolor,foregroundcolor});
            utils.updateOpacity(paramDlgs{idx},opacity);
        end
    end
end
