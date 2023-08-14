function[success,errormsg]=preApplyCB(obj,dlg)

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        success=true;
        errormsg='';
        return;
    end

    groupName=dlg.getWidgetValue('groupname');
    [values,labels,success,errormsg]=utils.validateDiscreteStates(obj);

    if~success
        return;
    end

    backgroundcolor=obj.BackgroundColor;
    foregroundcolor=obj.ForegroundColor;

    newLabelPosition=dlg.getComboBoxText('labelPosition');
    currentLabelPosition=get_param(blockHandle,'LabelPosition');

    blkGroupName=get_param(blockHandle,'ButtonGroupName');
    blkVals=get_param(blockHandle,'Values');
    curLabels=blkVals{1};
    curValues=blkVals{2};

    newEnableEnumDataTypeValue=dlg.getWidgetValue('EnableEnumDataType');
    newEnumDataTypeValue=dlg.getWidgetValue('EnumDataTypeName');


    if~strcmp(currentLabelPosition,newLabelPosition)
        newLabelPosition=simulink.hmi.getLabelPosition(newLabelPosition);
        set_param(blockHandle,'LabelPosition',newLabelPosition);
    end


    if~isequal(blkGroupName,groupName)
        set_param(blockHandle,'ButtonGroupName',groupName);
    end


    if newEnableEnumDataTypeValue
        newValue='on';
    else
        newValue='off';
    end
    set_param(blockHandle,'EnumeratedDataType',newEnumDataTypeValue);
    set_param(blockHandle,'UseEnumeratedDataType',newValue);

    if newEnableEnumDataTypeValue
        utils.updateDiscreteStates(blockHandle,obj.widgetId,false);
    end



    if~(isequal(labels,curLabels)&&isequal(values,curValues))&&...
        ~newEnableEnumDataTypeValue
        set_param(blockHandle,'Values',{labels,values});
        currentSelectedLabel=get_param(blockHandle,'SelectedLabel');
        searchResult=strcmp(labels,currentSelectedLabel);
        selectedIndex=find(searchResult,1);
        if~isempty(selectedIndex)
            set_param(blockHandle,'SelectedLabel',labels{selectedIndex});
        end
    end

    opacity=dlg.getWidgetValue('opacity');
    bindParameter(obj);
    set_param(mdl,'Dirty','on');
    set_param(blockHandle,'BackgroundColor',backgroundcolor);
    set_param(blockHandle,'ForegroundColor',foregroundcolor);
    set_param(blockHandle,'Opacity',opacity);

    scChannel='/hmi_radio_button_colors_controller_/';
    paramDlgs=obj.getOpenDialogs(true);
    for idx=1:length(paramDlgs)
        paramDlgs{idx}.enableApplyButton(false,false);
        if~isequal(dlg,paramDlgs{idx})
            utils.updateDiscreteStates(blockHandle,obj.widgetId,true);
            utils.enableEnumTypeChanged(paramDlgs{idx},obj,true);
            utils.updateOpacity(paramDlgs{idx},opacity);

            message.publish([scChannel,'updateColors'],...
            {false,obj.widgetId,mdl,backgroundcolor,foregroundcolor});
        end
    end
end
