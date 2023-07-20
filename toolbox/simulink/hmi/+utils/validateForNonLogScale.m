

function[success,errormsg,ticks]=validateForNonLogScale(dialog,isSlimDialog,...
    minimumValue,maximumValue,tickInterval,isTickIntervalAuto,scaleType)


    success=true;
    errormsg='';
    ticks=[];
    maxNumberOfTicksAllowed=150;

    if minimumValue<(-realmax)
        success=false;
        param=DAStudio.message('SimulinkHMI:dialogs:MinTickValue');
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueLessThanNegativeRealMax',param);
        if isSlimDialog
            dialog.setWidgetWithError('minimumValue',...
            DAStudio.UI.Util.Error('minimumValue','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    if minimumValue>realmax
        success=false;
        param=DAStudio.message('SimulinkHMI:dialogs:MinTickValue');
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueGreaterThanRealMax',param);
        if isSlimDialog
            dialog.setWidgetWithError('minimumValue',...
            DAStudio.UI.Util.Error('minimumValue','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    if maximumValue<(-realmax)
        success=false;
        param=DAStudio.message('SimulinkHMI:dialogs:MaxTickValue');
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueLessThanNegativeRealMax',param);
        if isSlimDialog
            dialog.setWidgetWithError('maximumValue',...
            DAStudio.UI.Util.Error('maximumValue','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    if maximumValue>realmax
        success=false;
        param=DAStudio.message('SimulinkHMI:dialogs:MaxTickValue');
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueGreaterThanRealMax',param);
        if isSlimDialog
            dialog.setWidgetWithError('maximumValue',...
            DAStudio.UI.Util.Error('maximumValue','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    if minimumValue>=maximumValue
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:MinMaxError');
        if isSlimDialog
            dialog.setWidgetWithError('minimumValue',...
            DAStudio.UI.Util.Error('minimumValue','Error',errormsg,[255,0,0,100]));
            dialog.setWidgetWithError('maximumValue',...
            DAStudio.UI.Util.Error('maximumValue','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    if~isTickIntervalAuto&&utils.isValidFloatField(tickInterval)||tickInterval<0
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:TickInterval'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:InvalidTimeSpanTickIntervalParameter',param);
        if isSlimDialog
            dialog.setWidgetWithError('tickInterval',...
            DAStudio.UI.Util.Error('tickInterval','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    if tickInterval<=0||tickInterval>=(maximumValue-minimumValue)
        success=false;
        param=num2str(maximumValue-minimumValue);
        errormsg=DAStudio.message('SimulinkHMI:dialogs:TickIntervalError',param);
        if isSlimDialog
            dialog.setWidgetWithError('tickInterval',...
            DAStudio.UI.Util.Error('tickInterval','Error',errormsg,[255,0,0,100]));
        end
        return;
    end


    if isTickIntervalAuto
        diffBetweenMaxAndMin=maximumValue-minimumValue;
        tickInterval=diffBetweenMaxAndMin/10;
    end
    ticks=utils.getMajorTicks(minimumValue,tickInterval,maximumValue,scaleType);
    if(length(ticks)>maxNumberOfTicksAllowed)||any(isnan(ticks))
        errormsg=DAStudio.message('SimulinkHMI:dialogs:MaxTicksError');
        success=false;
        if isSlimDialog
            dialog.setWidgetWithError('tickInterval',...
            DAStudio.UI.Util.Error('tickInterval','Error',errormsg,[255,0,0,100]));
        end
        return;
    end
end