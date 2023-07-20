function[success,errormsg]=preApplyCB(~,dlg)





    str=dlg.getWidgetValue('txtSubPlot');
    if~locIsSubPlotsValid(str)
        success=false;
        errormsg=getString(message('SDI:dialogs:SigSettingsSubPlotsError'));
        dlg.setWidgetWithError(...
        'txtSubPlot',...
        DAStudio.UI.Util.Error('txtSubPlot','Error',errormsg,[255,0,0,100]));
        return
    end
    dlg.clearWidgetWithError('txtSubPlot');

    if Simulink.sdi.enableTolerancesDataEntry()

        [success,errormsg]=locValidateTolerance(dlg,'txtRelativeTolerance');
        if~success
            return
        end
    end

    [success,errormsg]=locValidateTolerance(dlg,'txtAbsoluteTolerance');
    if~success
        return
    end
end


function ret=locIsSubPlotsValid(str)
    ret=true;

    try
        val=eval(sprintf('uint32([%s])',str));
    catch me %#ok<NASGU>
        ret=false;
        return
    end

    if any(val<1)||any(val>64)
        ret=false;
    end
end


function[success,errormsg]=locValidateTolerance(dlg,id)
    success=true;
    errormsg='';
    str=dlg.getWidgetValue(id);
    if~locIsToleranceValid(str)
        success=false;
        errormsg=getString(message('SDI:dialogs:SigSettingsTolError'));
        dlg.setWidgetWithError(...
        id,...
        DAStudio.UI.Util.Error(id,'Error',errormsg,[255,0,0,100]));
    else
        dlg.clearWidgetWithError(id);
    end
end


function ret=locIsToleranceValid(str)
    ret=isempty(str);
    if~ret
        val=str2double(str);
        ret=~isnan(val)&&isreal(val)&&val>=0;
    end
end
