

function[success,errormsg]=preApplyCB(obj,dlg)

    blockHandle=obj.getBlock.Handle;
    mdl=get_param(bdroot(blockHandle),'Name');
    success=true;
    errormsg='';

    if Simulink.HMI.isLibrary(mdl)
        return;
    end

    roundedPressDelay=round(str2double(dlg.getWidgetValue('PressDelay')));
    roundedRepeatInterval=round(str2double(dlg.getWidgetValue('RepeatInterval')));


    if isnan(roundedPressDelay)||(str2double(dlg.getWidgetValue('PressDelay'))<0)
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:PressDelayError');
        return;
    end

    if isnan(roundedRepeatInterval)||(str2double(dlg.getWidgetValue('RepeatInterval'))<0)
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:RepeatIntervalError');
        return;
    end

    warning off backtrace;
    if roundedPressDelay~=str2double(dlg.getWidgetValue('PressDelay'))
        warning('Press delay must be a positive integer or zero, input is rounded.');
    end

    if roundedRepeatInterval~=str2double(dlg.getWidgetValue('RepeatInterval'))
        warning('Repeat interval must be a positive integer or zero, input is rounded.');
    end
    warning on backtrace;

    set_param(obj,'PressFcn',dlg.getWidgetValue('PressFcn'));
    set_param(obj,'ButtonText',dlg.getWidgetValue('ButtonText'));
    set_param(obj,'ClickFcn',dlg.getWidgetValue('ClickFcn'));

    dlg.setWidgetValue('PressDelay',num2str(roundedPressDelay));
    dlg.setWidgetValue('RepeatInterval',num2str(roundedRepeatInterval));
    set_param(obj,'PressDelay',num2str(roundedPressDelay));
    set_param(obj,'RepeatInterval',num2str(roundedRepeatInterval));
    slDialogUtil(obj,'sync',dlg,'edit','PressDelay');
    slDialogUtil(obj,'sync',dlg,'edit','RepeatInterval');


    set_param(mdl,'Dirty','on');
    dlg.refresh;
end