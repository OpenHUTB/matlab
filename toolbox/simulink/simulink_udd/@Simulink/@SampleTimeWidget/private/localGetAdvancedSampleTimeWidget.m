function widget=localGetAdvancedSampleTimeWidget(stTag,stPrmIndex,stValue,typeTag,typeValue,source,allowedTypes,methods)



    try
        widget=getAdvancedSampleTimeWidget_Impl(...
        stTag,...
        stPrmIndex,...
        stValue,...
        typeTag,...
        typeValue,...
        source,...
        allowedTypes,...
        methods);
    catch ex


        disp(ex.getReport)
        rethrow(ex);
    end

end

function widget=getAdvancedSampleTimeWidget_Impl(stTag,stPrmIndex,stValue,typeTag,typeValue,source,allowedTypes,methods)













    if stPrmIndex<0
        stParamName=stTag;
        stTypeParamName=typeTag;
    else
        stParamName=source.getDialogParams{stPrmIndex+1};
        if~isempty(typeTag)
            stTypeParamName=[stParamName,'Type'];
            assert(strcmp(stTypeParamName,source.getDialogParams{stPrmIndex+2}));
        else
            stTypeParamName='';
        end
    end


    stEnabled=Simulink.isParameterEnabled(source.getBlock.handle,stParamName);
    if isempty(typeTag)
        stTypeEnabled=stEnabled;
    else
        stTypeEnabled=Simulink.isParameterEnabled(source.getBlock.handle,stTypeParamName);
    end


    intrinsicParameters=get_param(source.getBlock.handle,'IntrinsicDialogParameters');
    stPrompt=intrinsicParameters.(stParamName).Prompt;


    if~isempty(stTypeParamName)
        comboboxOptions=intrinsicParameters.(stTypeParamName).Enum;



        for i=1:length(comboboxOptions)
            comboboxOptions{i}=localConvertNameForLocale(comboboxOptions{i});
        end
    else




        allOptions={'Periodic','Continuous','Inherited',...
        'Auto','Unresolved'};



        comboboxOptions={};
        for i=1:length(allOptions)
            if isTypeEnabled(allOptions{i},allowedTypes)
                comboboxOptions{end+1}=localGetNameFromType(allOptions{i});%#ok
            end
        end
    end


    if~isempty(typeTag)
        assignedTypeTag=typeTag;
    else
        assignedTypeTag=[stTag,'|advSTWidgetCombobox'];
    end


    value.Type='edit';
    value.Tag=stTag;
    value=localHandleEditEvent(value,stPrmIndex,stValue,source,methods);
    if~stEnabled
        value.Enabled=false;
    end
    value.HideName=true;
    value.Name='Hidden Sample Time Widget';
    value.RowSpan=[1,1];
    value.ColSpan=[1,1];

    value.Visible=bitand(slfeature('EnableAdvancedSampleTimeWidget'),2)>0;
    value.UserData={stTag,assignedTypeTag,stTypeParamName};




    valuePanel.Type='panel';
    valuePanel.Tag=[stTag,'|ASTWValuePanel'];
    valuePanel.Items={value};
    valuePanel.LayoutGrid=[1,1];
    valuePanel.RowStretch=1;
    valuePanel.ColStretch=1;
    valuePanel.RowSpan=[1,1];
    valuePanel.ColSpan=[1,4];
    valuePanel.Visible=bitand(slfeature('EnableAdvancedSampleTimeWidget'),2)>0;



    prompt.Name=DAStudio.message('Simulink:blkprm_prompts:SampleTimeWidgetTypeLabel');
    prompt.Type='text';
    prompt.Tag=[stTag,'|Prompt_Tag'];
    prompt.RowSpan=[2,2];
    prompt.ColSpan=[1,1];

    prompt.Buddy=assignedTypeTag;


    combobox.Type='combobox';
    combobox.Tag=assignedTypeTag;
    combobox.Name='';
    if~stTypeEnabled
        combobox.Enabled=false;
    end
    combobox.ToolTip=...
    message('Simulink:SampleTime:SampleTimeWidgetTooltipCombobox',...
    message('Simulink:SampleTime:SampleTimeWidgetTypePeriodic').getString()).getString();
    combobox.UserData={stTag,assignedTypeTag};
    combobox.Entries=comboboxOptions;


    [type,storedValue]=localGetTypeAndValue(stValue,typeValue);

    if~isTypeEnabled(type,allowedTypes)
        type='Unresolved';
    end

    isPeriodicSelected=strcmp(type,'Periodic');
    isUnresolvedSelected=strcmp(type,'Unresolved');



    if~isempty(typeValue)

        combobox.Value=typeValue;
    else
        combobox.Value=localGetNameFromType(type);
    end
    combobox.HideName=true;
    combobox.Visible=true;
    combobox.RowSpan=[2,2];
    combobox.ColSpan=[2,2];


    combobox.MatlabMethod='Simulink.SampleTimeWidget.callbackAdvancedSampleTimeWidget';
    combobox.MatlabArgs={'callback_combobox','%dialog',stTag,assignedTypeTag};


    periodicValue='';
    if isPeriodicSelected||isUnresolvedSelected
        periodicValue=storedValue.string;
    end
    periodicPanel=getValuePanel(stTag,'periodicPanel',...
    periodicValue,'callback_periodicValue',...
    message('Simulink:SampleTime:SampleTimeWidgetTooltipPeriodic').getString(),...
    assignedTypeTag);
    if~stEnabled
        periodicPanel.Enabled=false;
    end
    periodicPanel.RowSpan=[2,2];
    periodicPanel.ColSpan=[3,3];
    periodicPanel.Visible=isPeriodicSelected;


    unresolvedPanel=getValuePanel(stTag,'unresolvedPanel',...
    storedValue.string,'callback_unresolvedSampletime',...
    message('Simulink:SampleTime:SampleTimeWidgetTooltipUnresolved').getString(),...
    assignedTypeTag);
    unresolvedPanel.Visible=isUnresolvedSelected;
    if~stEnabled
        unresolvedPanel.Enabled=false;
    end
    unresolvedPanel.RowSpan=[2,2];
    unresolvedPanel.ColSpan=[3,3];





    otherPanel=getValuePanel(stTag,'otherPanel',...
    storedValue.string,'ignore',...
    message('Simulink:SampleTime:SampleTimeWidgetTooltipOther').getString(),...
    assignedTypeTag);
    otherPanel.Visible=strcmp(type,'Auto')||...
    strcmp(type,'Continuous')||strcmp(type,'Inherited');
    otherPanel.Enabled=false;
    otherPanel.RowSpan=[2,2];
    otherPanel.ColSpan=[3,3];


    items={valuePanel,prompt,combobox,periodicPanel,unresolvedPanel,otherPanel};
    widget.Type='group';
    widget.Name=stPrompt;
    widget.Tag=[stTag,'|Panel_Tag'];
    widget.Items=items;
    widget.LayoutGrid=[3,3];
    widget.RowStretch=[1,1,1];
    widget.ColStretch=[0,0,1];

end






















function enabled=isTypeEnabled(type,allowedTypes)
    feature=slfeature('EnableAdvancedSampleTimeWidget');
    switch type
    case 'Periodic'
        enabled=bitand(allowedTypes,8)&&bitand(feature,8)>0;
    case 'Continuous'
        enabled=bitand(allowedTypes,16)&&bitand(feature,8)>0;
    case 'Inherited'
        enabled=bitand(allowedTypes,4)&&bitand(feature,8)>0;
    case 'Auto'
        enabled=bitand(allowedTypes,1)&&bitand(feature,8)>0;
    case 'Unresolved'
        enabled=true;
    otherwise
        enabled=false;
    end
end

function[panel]=getValuePanel(stTag,name,value,callback,tooltip,typeTag)






    tag=[stTag,'|',name];

    label.Type='text';
    label.Tag=[tag,'_valueLabel'];
    label.Name=DAStudio.message('Simulink:blkprm_prompts:SampleTimeWidgetValueLabel');
    label.ColSpan=[1,1];
    label.RowSpan=[1,1];

    editbox.Type='edit';
    editbox.Tag=[tag,'_value'];
    editbox.Value=value;
    editbox.HideName=true;
    editbox.ColSpan=[2,2];
    editbox.RowSpan=[1,1];
    editbox.MatlabMethod='Simulink.SampleTimeWidget.callbackAdvancedSampleTimeWidget';
    editbox.MatlabArgs={callback,'%dialog',stTag,typeTag};
    editbox.ToolTip=tooltip;


    label.Buddy=editbox.Tag;

    items={label,editbox};
    panel.Type='panel';
    panel.Tag=tag;
    panel.Items=items;
    panel.LayoutGrid=[1,2];
    panel.RowStretch=0;
    panel.ColStretch=[0,1];
end


