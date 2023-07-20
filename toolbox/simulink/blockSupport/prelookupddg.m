function dlgStruct=prelookupddg(source,h)








    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];

    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='tab';
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;
    paramGrp.Tabs={};

    paramGrp.Tabs{end+1}=get_main_tab(source,h);
    paramGrp.Tabs{end+1}=get_data_type_tab(source,h);




    dlgStruct.DialogTitle=DAStudio.message('Simulink:blkprm_prompts:BlockParameterDlg',strrep(h.Name,sprintf('\n'),' '));
    dlgStruct.DialogTag='PreLookup';
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};

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

end



function[BpData,BpDataValuePrompt,BpDataSource,BpDataSourcePrompt,BpDataValuesEdit]=...
    create_explicitDialogWidgets(source,h,rowIdx,isEvenlySpacingFormat,...
    isBPviaObject,isBPviaDialog)

    [BpDataValuePrompt,BpDataValue]=create_widget(source,h,'BreakpointsData',rowIdx+1,2,2);

    BpDataValuePrompt.Name=DAStudio.message('Simulink:blkprm_prompts:ParamValueLabelId');
    BpDataValuePrompt.RowSpan=[rowIdx,rowIdx];
    BpDataValuePrompt.ColSpan=[5,7];
    BpDataValuePrompt.Visible=~isEvenlySpacingFormat&&~isBPviaObject;

    BpDataValue.Name='';
    BpDataValue.RowSpan=[rowIdx+1,rowIdx+1];
    BpDataValue.ColSpan=[5,7];
    BpDataValue.Visible=~isEvenlySpacingFormat&&~isBPviaObject;
    BpDataValue.Enabled=~isEvenlySpacingFormat&&~isBPviaObject&&isBPviaDialog;
    BpDataValue.DialogRefresh=true;
    BpData=BpDataValue;


    [BpDataSourcePrompt,BpDataSource]=create_widget(source,h,'BreakpointsDataSource',rowIdx+1,2,2);

    BpDataSourcePrompt.Name=DAStudio.message('Simulink:blkprm_prompts:ParamSourceLabelId');
    BpDataSourcePrompt.RowSpan=[rowIdx,rowIdx];
    BpDataSourcePrompt.ColSpan=[4,4];
    BpDataSourcePrompt.Visible=~isEvenlySpacingFormat&&~isBPviaObject;

    BpDataSource.RowSpan=[rowIdx+1,rowIdx+1];
    BpDataSource.ColSpan=[4,4];
    BpDataSource.DialogRefresh=true;
    BpDataSource.Visible=~isEvenlySpacingFormat&&~isBPviaObject;
    BpDataSource.Enabled=~isEvenlySpacingFormat&&~isBPviaObject&&~source.isHierarchySimulating;


    BpDataValuesEdit.Name=DAStudio.message('Simulink:dialog:Editing');
    BpDataValuesEdit.Type='pushbutton';
    BpDataValuesEdit.RowSpan=[rowIdx+1,rowIdx+1];
    BpDataValuesEdit.ColSpan=[8,8];
    BpDataValuesEdit.MatlabMethod='luteditorddg_cb';
    BpDataValuesEdit.MatlabArgs={'%dialog',h};
    BpDataValuesEdit.Enabled=((isBPviaDialog||isEvenlySpacingFormat||isBPviaObject));
    BpDataValuesEdit.Visible=((isBPviaDialog||isEvenlySpacingFormat||isBPviaObject));

    if(~isBPviaDialog&&~isEvenlySpacingFormat&&~isBPviaObject)
        BpDataEditBox.Type='edit';
        BpDataEditBox.Name='';
        BpDataEditBox.RowSpan=[rowIdx+1,rowIdx+1];
        BpDataEditBox.ColSpan=[5,7];
        BpDataEditBox.Visible=true;
        BpDataEditBox.Enabled=false;
        BpData=BpDataEditBox;
    end
end


function[BpZeroLabel,BpZeroValue,BpSpaceLabel,BpSpaceValue,BpNumberLabel,BpNumberValue]=...
    createEvenSpacingDialogWidgets(source,h,rowIdx,isEvenlySpacingFormat)

    [BpZeroLabel,BpZeroValue]=create_widget(source,h,'BreakpointsFirstPoint',rowIdx+1,1,1);

    BpZeroLabel.RowSpan=[rowIdx,rowIdx];
    BpZeroLabel.ColSpan=[5,5];
    BpZeroLabel.Visible=isEvenlySpacingFormat;

    BpZeroValue.RowSpan=[rowIdx+1,rowIdx+1];
    BpZeroValue.ColSpan=[5,5];
    BpZeroValue.Visible=isEvenlySpacingFormat;
    BpZeroValue.Enabled=isEvenlySpacingFormat;


    [BpSpaceLabel,BpSpaceValue]=create_widget(source,h,'BreakpointsSpacing',rowIdx+1,1,1);

    BpSpaceLabel.RowSpan=[rowIdx,rowIdx];
    BpSpaceLabel.ColSpan=[6,6];
    BpSpaceLabel.Visible=isEvenlySpacingFormat;

    BpSpaceValue.RowSpan=[rowIdx+1,rowIdx+1];
    BpSpaceValue.ColSpan=[6,6];
    BpSpaceValue.Visible=isEvenlySpacingFormat;
    BpSpaceValue.Enabled=isEvenlySpacingFormat;


    [BpNumberLabel,BpNumberValue]=create_widget(source,h,'BreakpointsNumPoints',rowIdx+1,1,1);

    BpNumberLabel.RowSpan=[rowIdx,rowIdx];
    BpNumberLabel.ColSpan=[7,7];
    BpNumberLabel.Visible=isEvenlySpacingFormat;

    BpNumberValue.RowSpan=[rowIdx+1,rowIdx+1];
    BpNumberValue.ColSpan=[7,7];
    BpNumberValue.Visible=isEvenlySpacingFormat;
    BpNumberValue.Enabled=isEvenlySpacingFormat&&~source.isHierarchySimulating;


end

function[BPObjectLabel,BPObjectValue]=...
    createBPObjectDialogWidgets(source,h,rowIdx,isEvenlySpacingFormat,...
    isBPviaObject,isBPviaDialog)


    BPObjectLabel.Name='';
    BPObjectLabel.Type='text';
    BPObjectLabel.RowSpan=[rowIdx,rowIdx];
    BPObjectLabel.ColSpan=[1,1];
    BPObjectLabel.Enabled=false;
    BPObjectLabel.Visible=false;

    BPObjectValue.Name='';
    BPObjectValue.Type='text';
    BPObjectValue.RowSpan=[rowIdx,rowIdx];
    BPObjectValue.ColSpan=[1,1];
    BPObjectValue.Enabled=false;
    BPObjectValue.Visible=false;


    [BPObjectLabel,BPObjectValue]=create_widget(source,h,'BreakpointObject',rowIdx+1,2,2);


    BPObjectLabel.Name=DAStudio.message('Simulink:blkprm_prompts:ParamNameLabelId');
    BPObjectLabel.RowSpan=[rowIdx,rowIdx];
    BPObjectLabel.ColSpan=[4,7];
    BPObjectLabel.Visible=isBPviaObject;

    BPObjectValue.Name='';
    BPObjectValue.RowSpan=[rowIdx+1,rowIdx+1];
    BPObjectValue.ColSpan=[4,7];
    BPObjectValue.Visible=isBPviaObject;
    BPObjectValue.Enabled=isBPviaObject;
    BPObjectValue.DialogRefresh=true;

end





function[BreakpointGroup,rowIdx]=get_breakpoints_group(source,h,rowIdx)
    isEvenlySpacingFormat=(strcmp(h.BreakpointsSpecification,'Even spacing'));
    isBPviaObject=strcmp(h.BreakpointsSpecification,'Breakpoint object');
    isBPviaDialog=~isEvenlySpacingFormat&&~isBPviaObject&&...
    strcmp(h.BreakpointsDataSource,'Dialog');




    [BpDataFormatLabel,BpDataFormat]=create_widget(source,h,'BreakpointsSpecification',rowIdx+1,2,2);

    BpDataFormatLabel.RowSpan=[rowIdx,rowIdx];
    BpDataFormatLabel.ColSpan=[3,3];

    BpDataFormat.RowSpan=[rowIdx+1,rowIdx+1];
    BpDataFormat.ColSpan=[3,3];
    BpDataFormat.Visible=true;
    BpDataFormat.Enabled=~source.isHierarchySimulating;
    BpDataFormat.DialogRefresh=true;



    [BpData,BpDataValuePrompt,BpDataSource,BpDataSourcePrompt,BpDataValuesEdit]=...
    create_explicitDialogWidgets(source,h,rowIdx,isEvenlySpacingFormat,...
    isBPviaObject,isBPviaDialog);


    [BpZeroLabel,BpZeroValue,BpSpaceLabel,BpSpaceValue,BpNumberLabel,BpNumberValue]=...
    createEvenSpacingDialogWidgets(source,h,rowIdx,isEvenlySpacingFormat);

    [BPObjectLabel,BPObjectValue]=createBPObjectDialogWidgets(source,h,rowIdx,...
    isEvenlySpacingFormat,...
    isBPviaObject,isBPviaDialog);


    rowIdx=rowIdx+1;


    BreakpointGroup.Name=DAStudio.message('Simulink:blkprm_prompts:BreakpointsParamGroupLabelId');
    BreakpointGroup.Type='group';
    BreakpointGroup.RowSpan=[1,2];
    BreakpointGroup.ColSpan=[1,8];
    BreakpointGroup.LayoutGrid=[2,8];
    BreakpointGroup.ColStretch=[0,0,0,0,1,1,1,0];

    BreakpointGroup.Items={BpDataFormatLabel,BpDataSourcePrompt,BpDataValuePrompt,...
    BPObjectLabel,BPObjectValue,BpZeroLabel,...
    BpSpaceLabel,BpNumberLabel,BpDataFormat,BpDataSource,...
    BpData,BpZeroValue,BpSpaceValue,BpNumberValue,BpDataValuesEdit};
end


function thisTab=get_main_tab(source,h)

    rowIdx=1;

    isEvenlySpacingFormat=(strcmp(h.BreakpointsSpecification,'Even spacing'));

    [BreakpointGroup,rowIdx]=get_breakpoints_group(source,h,rowIdx);

    rowIdx=rowIdx+1;
    [OutputFormat_prompt,OutputFormat_value]=create_widget(source,h,'OutputSelection',rowIdx+1,2,2);
    OutputFormat_prompt.RowSpan=[rowIdx,rowIdx];
    OutputFormat_prompt.ColSpan=[1,2];

    OutputFormat_value.RowSpan=[rowIdx,rowIdx];
    OutputFormat_value.ColSpan=[3,4];

    OutputFormat_value.DialogRefresh=true;










    rowIdx=rowIdx+1;

    [indexSearch_prompt,indexSearch_value]=create_widget(source,h,'IndexSearchMethod',rowIdx,2,2);
    indexSearch_prompt.RowSpan=[rowIdx,rowIdx];
    indexSearch_prompt.ColSpan=[1,2];

    indexSearch_value.RowSpan=[rowIdx,rowIdx];
    indexSearch_value.ColSpan=[3,4];
    indexSearch_value.Visible=~isEvenlySpacingFormat;
    indexSearch_value.Enabled=~isEvenlySpacingFormat&&~source.isHierarchySimulating;
    indexSearch_value.DialogRefresh=true;

    evenlySpacedEditBox.Name=DAStudio.message('SimulinkBlocks:dialog:Evenly_spaced_points_CB');
    evenlySpacedEditBox.Type='text';
    evenlySpacedEditBox.RowSpan=[rowIdx,rowIdx];
    evenlySpacedEditBox.ColSpan=[3,4];
    evenlySpacedEditBox.Visible=isEvenlySpacingFormat;
    evenlySpacedEditBox.Enabled=isEvenlySpacingFormat;



    isEvenlySpacedPoints=strcmp(h.IndexSearchMethod,'Evenly spaced points');
    prevIndexVal=create_widget(source,h,'BeginIndexSearchUsingPreviousIndexResult',rowIdx,2,2);
    prevIndexVal.RowSpan=[rowIdx,rowIdx];
    prevIndexVal.ColSpan=[5,8];
    prevIndexVal.Visible=(~isEvenlySpacedPoints&&~isEvenlySpacingFormat);
    prevIndexVal.Enabled=(~isEvenlySpacedPoints&&~isEvenlySpacingFormat&&~source.isHierarchySimulating);
    prevIndexVal.DialogRefresh=true;
















    rowIdx=rowIdx+1;

    [outRangeInput_prompt,outRangeInput_value]=create_widget(source,h,'ExtrapMethod',rowIdx,2,2);
    outRangeInput_prompt.RowSpan=[rowIdx,rowIdx];
    outRangeInput_prompt.ColSpan=[1,2];

    outRangeInput_value.RowSpan=[rowIdx,rowIdx];
    outRangeInput_value.ColSpan=[3,4];
    outRangeInput_value.DialogRefresh=true;



    useLastBpVal=create_widget(source,h,'UseLastBreakpoint',rowIdx,2,2);
    useLastBpVal.RowSpan=[rowIdx,rowIdx];
    useLastBpVal.ColSpan=[5,8];
    if(strcmp(h.OutputOnlyTheIndex,'off')&&strcmp(h.ExtrapMethod,'Clip'))
        useLastBpVal.Visible=true;
        useLastBpVal.Enabled=true&&~source.isHierarchySimulating;
    else
        useLastBpVal.Visible=false;
        useLastBpVal.Enabled=false&&~source.isHierarchySimulating;
    end

    rowIdx=rowIdx+1;

    [outRangeAction_prompt,outRangeAction_value]=create_widget(source,h,'DiagnosticForOutOfRangeInput',rowIdx,2,2);
    outRangeAction_prompt.RowSpan=[rowIdx,rowIdx];
    outRangeAction_prompt.ColSpan=[1,2];

    outRangeAction_value.RowSpan=[rowIdx,rowIdx];
    outRangeAction_value.ColSpan=[3,4];

    rowIdx=rowIdx+1;


    AlgorithmGroup.Name=DAStudio.message('Simulink:dialog:AlgorithmTab');
    AlgorithmGroup.Type='group';
    AlgorithmGroup.RowSpan=[3,6];
    AlgorithmGroup.ColSpan=[1,8];
    AlgorithmGroup.LayoutGrid=[4,8];
    AlgorithmGroup.ColStretch=[0,0,0,0,0,0,0,1];

    AlgorithmGroup.Items={OutputFormat_prompt,OutputFormat_value,...
    indexSearch_prompt,evenlySpacedEditBox,indexSearch_value,prevIndexVal,...
    outRangeInput_prompt,outRangeInput_value,...
    useLastBpVal,outRangeAction_prompt,outRangeAction_value};

    rowIdx=rowIdx+1;

    checkCodeInRange=create_widget(source,h,'RemoveProtectionInput',rowIdx,2,2);

    cgGroup.Name=DAStudio.message('Simulink:dialog:GroupCodeGeneration');
    cgGroup.Type='group';
    cgGroup.RowSpan=[checkCodeInRange.RowSpan(1),checkCodeInRange.RowSpan(2)];
    cgGroup.ColSpan=[1,8];
    cgGroup.LayoutGrid=[
    cgGroup.RowSpan(2)-cgGroup.RowSpan(1)+1...
    ,cgGroup.ColSpan(2)-cgGroup.ColSpan(1)+2];
    cgGroup.ColStretch=[ones(1,cgGroup.LayoutGrid(2)-1),8];
    rowOffset=checkCodeInRange.RowSpan(1)-1;
    checkCodeInRange.RowSpan=checkCodeInRange.RowSpan-rowOffset;
    cgGroup.Items={checkCodeInRange};

    rowIdx=rowIdx+1;

    ts=Simulink.SampleTimeWidget.getCustomDdgWidget(...
    source,h,'SampleTime','',rowIdx,2,2);
    ts.RowSpan=[rowIdx,rowIdx];
    ts.ColSpan=[1,1];

    rowIdx=rowIdx+1;


    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,8];

    thisTab.Name=DAStudio.message('Simulink:dialog:ModelTabOneName');


    thisTab.Items={BreakpointGroup,AlgorithmGroup,cgGroup,ts,spacer};

    thisTab.LayoutGrid=[rowIdx,8];
    thisTab.ColStretch=[0,0,0,0,0,0,0,1];
    thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];

end


function thisTab=get_data_type_tab(source,h)



    isBPviaObject=(strcmp(h.BreakpointsSpecification,'Breakpoint object'));
    isEvenlySpacingFormat=(strcmp(h.BreakpointsSpecification,'Even spacing'));
    bpFromDlg=~isEvenlySpacingFormat&&~isBPviaObject&&...
    strcmp(h.BreakpointsDataSource,'Dialog');

    indexOnly=strcmp(h.OutputSelection,'Index only');

    if(bpFromDlg||isEvenlySpacingFormat)
        if(indexOnly)
            paramList=[0,1];
        else
            paramList=[0,1,2];
        end
    else
        if(indexOnly)
            paramList=1;
        else
            paramList=[1,2];
        end
    end

    isOutputAsBus=strcmp(h.OutputSelection,'Index and fraction as bus');
    if(isOutputAsBus)

        paramList=[paramList,3];
        busSpecs=get_data_type_specs(source,h,paramList(end));
        isVirtualBus=strcmp(busSpecs.dtVal,'Inherit: auto');
        if~isVirtualBus||(isVirtualBus&&slfeature('SL_PRELOOKUP_INTERP_VIRTUAL_BUS_SUPPORT')==0)
            paramList=paramList(paramList~=1);
            paramList=paramList(paramList~=2);
        end
    end

    numParam=length(paramList);


    udtSpecs=cell(1,numParam);
    for paramIdx=1:numParam
        udtSpecs{paramIdx}=get_data_type_specs(source,h,paramList(paramIdx));
    end

    [orderedWidgets,maxRows,maxCols]=lut_create_data_type_widgets(source,h,udtSpecs);

    rowIdx=maxRows+1;

    lockOutScale=create_widget(source,h,'LockScale',rowIdx,2,2);
    lockOutScale.RowSpan=[rowIdx,rowIdx];
    lockOutScale.ColSpan=[1,maxCols];

    rowIdx=rowIdx+1;

    round=create_widget(source,h,'RndMeth',rowIdx,2,2);
    round.RowSpan=[rowIdx,rowIdx];
    round.ColSpan=[1,2];
    round.Editable=0;
    round.Visible=~indexOnly;
    round.Enabled=round.Enabled&&round.Visible;


    rowIdx=rowIdx+1;

    spacer.Name='';

    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,maxCols+3];



    thisTab.Items=[...
    orderedWidgets,...
    {lockOutScale,...
    round,...
spacer...
    }];

    thisTab.Name=DAStudio.message('Simulink:dialog:DataTypesTab');

    thisTab.LayoutGrid=[rowIdx,maxCols+3];
    thisTab.ColStretch=[0,1,1,1,1,0,0,0];
    thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];

end


function dataTypeSpec=get_data_type_specs(source,h,paramNumber)



    switch(paramNumber)
    case 0
        paramPrefix='Breakpoint';
        paramName=[paramPrefix,'DataTypeStr'];
        promptString=DAStudio.message('Simulink:dialog:BreakPointPrompt');
        scalingModesSelect='BPt_SB_Best';
        inheritRulesSelect='In_IR_TD';
        builtinSelect='Num';
        scalingValues={'BreakpointsData'};
        useMinMax=true;
        dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList(builtinSelect);
        dataTypeItems.supportsEnumType=true;
        dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList(scalingModesSelect);

    case 1
        paramPrefix='Index';
        paramName=[paramPrefix,'DataTypeStr'];
        promptString=DAStudio.message('Simulink:dialog:IndexTypePrompt');
        scalingModesSelect='Int';
        inheritRulesSelect='';
        builtinSelect='Int';
        scalingValues={};
        useMinMax=false;
        dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList(builtinSelect);
        dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList(scalingModesSelect);

    case 2
        paramPrefix='Fraction';
        paramName=[paramPrefix,'DataTypeStr'];
        promptString=DAStudio.message('Simulink:dialog:FractionTypePrompt');
        scalingModesSelect='BPt';
        inheritRulesSelect='IR';
        builtinSelect='Float';
        scalingValues={};
        useMinMax=false;
        dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList(builtinSelect);
        dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList(scalingModesSelect);

    case 3
        paramPrefix='OutputBus';
        paramName=[paramPrefix,'DataTypeStr'];
        promptString=DAStudio.message('Simulink:blkprm_prompts:OutputBusDataType');
        inheritRulesSelect='Auto';
        dataTypeItems.supportsBusType=true;
        scalingValues={};
        useMinMax=false;
    end

    if(~isempty(inheritRulesSelect))
        dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList(inheritRulesSelect);
    end
    dataTypeItems.scalingValueTags=scalingValues;

    if useMinMax
        dataTypeItems.scalingMinTag={[paramPrefix,'Min']};
        dataTypeItems.scalingMaxTag={[paramPrefix,'Max']};
    else
        dataTypeItems.scalingMinTag={};
        dataTypeItems.scalingMaxTag={};
    end

    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');

    dataTypeSpec.hDlgSource=source;
    dataTypeSpec.dtName=paramName;
    dataTypeSpec.dtPrompt=promptString;
    dataTypeSpec.dtTag=paramName;
    dataTypeSpec.dtVal=h.(paramName);
    dataTypeSpec.customAsstName=false;
    dataTypeSpec.dtaItems=dataTypeItems;

end
