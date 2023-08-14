function dlgStruct=enumconstddg(source,h)




    isNotSimulating=~source.isHierarchySimulating;
    valueStr=h.Value;
    dtStr=h.OutDataTypeStr;





    rowIdx=1;

    descTxt.Name=DAStudio.message('Simulink:blocks:EnumConstBlockDescription');
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=DAStudio.message('Simulink:blocks:EnumConstBlockType');
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[rowIdx,rowIdx];
    descGrp.ColSpan=[1,1];





    rowIdx=rowIdx+1;
    typeNameOptions.supportsEnumType=true;
    typeNameOptions.allowsExpression=false;
    typeName=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
    'OutDataTypeStr',...
    DAStudio.message('Simulink:blocks:EnumConstTypePrompt'),...
    'OutDataTypeStr',...
    dtStr,...
    typeNameOptions,...
    false);
    typeName.RowSpan=[rowIdx,rowIdx];
    typeName.ColSpan=[1,1];

    for idx=1:length(typeName.Items)
        if strcmp(typeName.Items{idx}.Tag,'OutDataTypeStr')
            typeName.Items{idx}.DialogRefresh=true;
        end
    end
    typeName.Enabled=isNotSimulating;





    rowIdx=rowIdx+1;
    value.Name=DAStudio.message('Simulink:blocks:EnumConstValuePrompt');
    value.RowSpan=[rowIdx,rowIdx];
    value.ColSpan=[1,1];
    value.Type='combobox';
    value.Source=h;
    value.ObjectProperty='Value';
    value.Tag='Value';
    value.Editable=true;
    value.Entries=l_GetListOfAllowableValues(dtStr);


    if(~isempty(value.Entries)&&...
        isempty(find(strcmp(value.Entries,valueStr),1)))
        value.Entries=[{valueStr};value.Entries];
    end





    rowIdx=rowIdx+1;
    sampleTime.Name=DAStudio.message('Simulink:blocks:EnumConstSampleTimePrompt');
    sampleTime.RowSpan=[rowIdx,rowIdx];
    sampleTime.ColSpan=[1,1];
    sampleTime.Type='edit';
    sampleTime.Source=h;
    sampleTime.ObjectProperty='SampleTime';
    sampleTime.Tag='SampleTime';
    sampleTime.Enabled=isNotSimulating;




    rowIdx=rowIdx+1;
    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,1];




    dlgStruct.DialogTitle=DAStudio.message('Simulink:blocks:EnumConstBlockType');
    dlgStruct.DialogTag='EnumeratedConstant';
    dlgStruct.Items={descGrp,typeName,value,sampleTime,spacer};
    dlgStruct.LayoutGrid=[rowIdx,1];
    dlgStruct.RowStretch=[zeros(1,(rowIdx-1)),1];
    dlgStruct.ColStretch=1;
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle};

    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end





    function enumNames=l_GetListOfAllowableValues(dtStr)


        try
            className=enumconst_cb('GetClassName',dtStr);

            [~,enumNames]=enumeration(className);
            for idx=1:length(enumNames)
                enumNames{idx}=[className,'.',enumNames{idx}];
            end
        catch e %#ok

            enumNames={DAStudio.message('Simulink:blocks:EnumConstValueForInvalidDataType')};
        end



