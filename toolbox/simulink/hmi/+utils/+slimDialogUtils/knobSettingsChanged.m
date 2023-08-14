


function knobSettingsChanged(dlg,obj)
    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end


    minVal=strtrim(dlg.getWidgetValue('minimumValue'));
    maxVal=strtrim(dlg.getWidgetValue('maximumValue'));
    tickVal=strtrim(dlg.getWidgetValue('tickInterval'));
    scaleType=simulink.hmi.getScaleType(dlg.getComboBoxText('scaleType'));
    if scaleType
        scaleTypeStr='Log';
    else
        scaleTypeStr='Linear';
    end
    success=...
    utils.validateMinMaxTickIntervalFields(minVal,maxVal,tickVal,dlg,true,scaleTypeStr);
    if~success
        return
    end


    set_param(blockHandle,'ScaleMin',minVal);
    set_param(blockHandle,'ScaleMax',maxVal);
    set_param(blockHandle,'TickInterval',tickVal);
    set_param(blockHandle,'ScaleType',scaleType);

    dlg.clearWidgetWithError('minimumValue');
    dlg.clearWidgetWithError('maximumValue');
    dlg.clearWidgetWithError('tickInterval');
    dlg.clearWidgetWithError('scaleType');

    dlg.clearWidgetDirtyFlag('minimumValue');
    dlg.clearWidgetDirtyFlag('maximumValue');
    dlg.clearWidgetDirtyFlag('tickInterval');
    dlg.clearWidgetDirtyFlag('scaleType');
end
