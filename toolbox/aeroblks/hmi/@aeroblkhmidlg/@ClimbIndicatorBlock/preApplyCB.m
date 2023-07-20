function[success,errormsg]=preApplyCB(obj,dlg)




    success=true;
    errormsg='';

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if utils.isAeroHMILibrary(mdl)
        return
    end


    maxVal=strtrim(dlg.getWidgetValue('maximumValue'));
    success=...
    utils.validateMinMaxTickIntervalFields('0',maxVal,'auto',dlg,false);
    if~success
        return
    end


    labelPosition=simulink.hmi.getLabelPosition(dlg.getComboBoxText('labelPosition'));


    set_param(blockHandle,'ScaleMax',maxVal,'LabelPosition',labelPosition);


    bindSignal(obj);



    signalDlgs=obj.getOpenDialogs(true);
    for j=1:length(signalDlgs)
        signalDlgs{j}.enableApplyButton(false,false);

        if~isequal(dlg,signalDlgs{j})

            utils.updateLabelPosition(signalDlgs{j},labelPosition);

            signalDlgs{j}.clearWidgetWithError('maximumValue');
            signalDlgs{j}.setWidgetValue('maximumValue',maxVal);
            signalDlgs{j}.clearWidgetDirtyFlag('maximumValue');
            signalDlgs{j}.enableApplyButton(false,false);

        end
    end
end
