


function[success,errormsg]=validateAxisLimits(timeSpan,yMin,yMax,dialog,isSlimDialog)
    success=true;
    errormsg='';


    isTimeSpanAuto=strcmpi(timeSpan,'auto');
    timeSpan=str2double(timeSpan);
    if~isTimeSpanAuto&&...
        (utils.isValidFloatField(timeSpan)||timeSpan<=0||isinf(timeSpan))
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:TimeSpan'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:InvalidTimeSpanTickIntervalParameter',param);
        if isSlimDialog
            dialog.setWidgetWithError('ScopeTimeSpan',...
            DAStudio.UI.Util.Error('ScopeTimeSpan','Error',errormsg,[255,0,0,100]));
        end
        return;
    end


    yMinLimit=str2double(yMin);
    if utils.isValidFloatField(yMinLimit)
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:Minimum'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericParameter',param);
        if isSlimDialog
            dialog.setWidgetWithError('yMinLabel',...
            DAStudio.UI.Util.Error('yMinLabel','Error',errormsg,[255,0,0,100]));
        end
        return;
    elseif yMinLimit<-realmax
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:Minimum'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueLessThanNegativeRealMax',param);
        if isSlimDialog
            dialog.setWidgetWithError('yMinLabel',...
            DAStudio.UI.Util.Error('yMinLabel','Error',errormsg,[255,0,0,100]));
        end
        return;
    elseif yMinLimit>realmax
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:Minimum'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueGreaterThanRealMax',param);
        if isSlimDialog
            dialog.setWidgetWithError('yMinLabel',...
            DAStudio.UI.Util.Error('yMinLabel','Error',errormsg,[255,0,0,100]));
        end
        return;
    end
    if isSlimDialog
        dialog.clearWidgetWithError('yMinLabel');
    end


    yMaxLimit=str2double(yMax);
    if utils.isValidFloatField(yMaxLimit)
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:Maximum'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:NonNumericParameter',param);
        if isSlimDialog
            dialog.setWidgetWithError('yMaxLabel',...
            DAStudio.UI.Util.Error('yMaxLabel','Error',errormsg,[255,0,0,100]));
        end
        return;
    elseif yMaxLimit<-realmax
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:Maximum'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueLessThanNegativeRealMax',param);
        if isSlimDialog
            dialog.setWidgetWithError('yMaxLabel',...
            DAStudio.UI.Util.Error('yMaxLabel','Error',errormsg,[255,0,0,100]));
        end
        return;
    elseif yMaxLimit>realmax
        success=false;
        param=sprintf('''%s''',DAStudio.message('SimulinkHMI:dialogs:Maximum'));
        errormsg=DAStudio.message('SimulinkHMI:dialogs:ValueGreaterThanRealMax',param);
        if isSlimDialog
            dialog.setWidgetWithError('yMaxLabel',...
            DAStudio.UI.Util.Error('yMaxLabel','Error',errormsg,[255,0,0,100]));
        end
        return;
    end
    if isSlimDialog
        dialog.clearWidgetWithError('yMaxLabel');
    end

    if yMinLimit>=yMaxLimit
        success=false;
        errormsg=DAStudio.message('SimulinkHMI:dialogs:HMIScopeYAxisMinMaxError');
        if isSlimDialog
            dialog.setWidgetWithError('yMinLabel',...
            DAStudio.UI.Util.Error('yMinLabel','Error',errormsg,[255,0,0,100]));
        end
        if isSlimDialog
            dialog.setWidgetWithError('yMaxLabel',...
            DAStudio.UI.Util.Error('yMaxLabel','Error',errormsg,[255,0,0,100]));
        end
        return;
    end

    if success&&isSlimDialog
        dialog.clearWidgetWithError('ScopeTimeSpan');
        dialog.clearWidgetWithError('yMaxLabel');
        dialog.clearWidgetWithError('yMinLabel');
    end
end
