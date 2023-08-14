function[success,errormsg]=preApplyCB(obj,dlg)

    blockHandle=get(obj.blockObj,'handle');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        success=true;
        errormsg='';
        return;
    end

    [values,labels,success,errormsg]=utils.validateDiscreteStates(obj);

    if~success
        return;
    end

    blkVals=get_param(blockHandle,'Values');
    curLabels=blkVals{1};
    curValues=blkVals{2};

    newEnableEnumDataTypeValue=dlg.getWidgetValue('EnableEnumDataType');
    newEnumDataTypeValue=dlg.getWidgetValue('EnumDataTypeName');

    newLabelPosition=simulink.hmi.getLabelPosition(...
    dlg.getComboBoxText('labelPosition'));



    set_param(blockHandle,'BulkUpdateMode','on');
    tmp=onCleanup(@()set_param(blockHandle,'BulkUpdateMode','off'));

    set_param(blockHandle,'LabelPosition',newLabelPosition);


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

    bindParameter(obj);
    set_param(mdl,'Dirty','on');

    paramDlgs=obj.getOpenDialogs(true);
    for idx=1:length(paramDlgs)
        paramDlgs{idx}.enableApplyButton(false,false);
        if~isequal(dlg,paramDlgs{idx})
            utils.updateDiscreteStates(blockHandle,obj.widgetId,true);
            utils.enableEnumTypeChanged(paramDlgs{idx},obj,true);
        end
    end
end
