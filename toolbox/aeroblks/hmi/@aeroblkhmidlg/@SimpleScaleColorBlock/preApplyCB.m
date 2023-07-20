function[success,errormsg]=preApplyCB(obj,dlg)




    success=true;
    errormsg='';

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if utils.isAeroHMILibrary(mdl)
        return
    end


    minVal=strtrim(dlg.getWidgetValue('minimumValue'));
    maxVal=strtrim(dlg.getWidgetValue('maximumValue'));
    [success,errormsg]=...
    utils.validateMinMaxTickIntervalFields(minVal,maxVal,'auto',dlg,false);
    if~success
        return
    end
    [success,errormsg]=utils.gaugeAeroValidateScaleColors(obj);
    if~success
        return
    end


    labelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));


    set_param(blockHandle,'ScaleMin',minVal,'ScaleMax',...
    maxVal,'LabelPosition',labelPosition,'ScaleColors',obj.ScaleColors);


    bindSignal(obj);



    signalDlgs=obj.getOpenDialogs(true);
    for j=1:length(signalDlgs)
        signalDlgs{j}.enableApplyButton(false,false);
        if~isequal(dlg,signalDlgs{j})
            props{1}=minVal;
            props{2}=maxVal;
            utils.updateAeroMinMaxIntervalFields(signalDlgs{j},props);
            utils.updateScaleColors(obj,dlg);
            utils.updateLabelPosition(signalDlgs{j},labelPosition);
        end
    end
end
