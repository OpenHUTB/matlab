

function[success,errormsg]=preApplyCB(obj,dlg)

    success=true;
    errormsg='';

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
    [success,errormsg]=...
    utils.validateMinMaxTickIntervalFields(minVal,maxVal,tickVal,dlg,false,scaleTypeStr);
    if~success
        return
    end


    labelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));



    set_param(blockHandle,'BulkUpdateMode','on');
    tmp=onCleanup(@()set_param(blockHandle,'BulkUpdateMode','off'));


    set_param(blockHandle,'ScaleMin',minVal);
    set_param(blockHandle,'ScaleMax',maxVal);
    set_param(blockHandle,'TickInterval',tickVal);
    set_param(blockHandle,'ScaleType',scaleType);
    set_param(blockHandle,'LabelPosition',labelPosition);


    bindParameter(obj);



    paramDlgs=obj.getOpenDialogs(true);
    for j=1:length(paramDlgs)
        paramDlgs{j}.enableApplyButton(false,false);

        if~isequal(dlg,paramDlgs{j})
            props.ScaleMin=minVal;
            props.ScaleMax=maxVal;
            props.Tick=tickVal;
            props.ScaleType=scaleType;

            utils.updateKnobSettings(paramDlgs{j},props);
            utils.updateLabelPosition(paramDlgs{j},labelPosition);
        end
    end
end
