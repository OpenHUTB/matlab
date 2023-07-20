

function[success,errormsg,ticks]=validateForLogScale(dialog,isSlimDialog,...
    minimumValue,maximumValue,tickIntervalExp,isTickIntervalAuto,scaleType)

    success=true;
    errormsg='';
    ticks=[];
    maxNumberOfTicksAllowed=150;

    if minimumValue<=0
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:LogPositiveTickValue');
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

    if maximumValue<=0
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:LogPositiveTickValue');
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

    if~isTickIntervalAuto&&...
        ~locIsIntegralValue(tickIntervalExp)||tickIntervalExp<1
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:LogTickInterval');
        if isSlimDialog
            dialog.setWidgetWithError('tickInterval',...
            DAStudio.UI.Util.Error('tickInterval','Error',errormsg,[255,0,0,100]));
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


    if isTickIntervalAuto
        tickIntervalExp=utils.getAutoTickIntervalExponent(minimumValue,maximumValue);
    end
    tickInterval=10^tickIntervalExp;


    if(tickInterval>(maximumValue/minimumValue))
        success=false;
        if isfinite(tickInterval)
            errormsg=DAStudio.message('SimulinkHMI:dialogs:LogTickIntervalMaxError',...
            tickIntervalExp);
        else
            errormsg=DAStudio.message('SimulinkHMI:dialogs:MaxTicksError');
        end
        if isSlimDialog
            dialog.setWidgetWithError('tickInterval',...
            DAStudio.UI.Util.Error('tickInterval','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    ticks=utils.getMajorTicks(minimumValue,tickInterval,maximumValue,scaleType);
    if(length(ticks)>maxNumberOfTicksAllowed)
        errormsg=DAStudio.message('SimulinkHMI:dialogs:MaxTicksError');
        success=false;
        if isSlimDialog
            dialog.setWidgetWithError('tickInterval',...
            DAStudio.UI.Util.Error('tickInterval','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

end

function bIntegral=locIsIntegralValue(val)
    bIntegral=false;
    if(mod(val,1)==0)
        bIntegral=true;
    end
end