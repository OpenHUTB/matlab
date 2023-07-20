function dlgStruct=interpndddg(source,h)








    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    rowIdx=1;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[rowIdx,rowIdx];
    descGrp.ColSpan=[1,1];


    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='tab';
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;
    paramGrp.Tabs={};

    paramGrp.Tabs{end+1}=get_main_tab(source,h);
    paramGrp.Tabs{end+1}=get_data_type_tab(source,h);





    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.DialogTag='Interpolation_n-D';
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


function thisTab=get_main_tab(source,h)


    maxCols=6;
    rowIdx=1;

    DataGroup.Name=DAStudio.message('Simulink:blkprm_prompts:TableParamGroupLabelId');
    DataGroup.Type='group';
    DataGroup.RowSpan=[1,3];

    DataGroup.ColSpan=[1,maxCols];
    DataGroup.LayoutGrid=[3,maxCols];
    DataGroup.ColStretch=[0,0,0,0,0,0];

    [NumDimPrompt,NumDimValues]=create_widget(source,h,'NumberOfTableDimensions',rowIdx,2,2);
    NumDimPrompt.RowSpan=[rowIdx,rowIdx];
    NumDimPrompt.ColSpan=[1,2];
    NumDimValues.Type='combobox';
    NumDimValues.Entries={'1','2','3','4'};
    NumDimValues.Editable=1;
    NumDimValues.DialogRefresh=true;
    NumDimValues.RowSpan=[rowIdx,rowIdx];
    NumDimValues.ColSpan=[2,2];

    expectBusInput=create_widget(source,h,'RequireIndexFractionAsBus',rowIdx,2,2);
    expectBusInput.RowSpan=[rowIdx,rowIdx];
    expectBusInput.ColSpan=[3,4];
    DataGroup.Items={NumDimPrompt,NumDimValues,expectBusInput};


    rowIdx=rowIdx+1;

    [DataGroup,rowIdx]=get_LUTObjectDialogs(source,h,rowIdx,DataGroup);
    isLookupTableObject=strcmp(h.TableSpecification,'Lookup table object');


    [DataGroup,rowIdx]=create_table(source,h,rowIdx,maxCols,DataGroup,isLookupTableObject);



    algGrpStartRowIdx=rowIdx;
    [interp_prompt,interp_value]=create_widget(source,h,'InterpMethod',rowIdx,2,2);
    interp_prompt.RowSpan=[rowIdx,rowIdx];
    interp_prompt.ColSpan=[1,1];
    interp_value.RowSpan=[rowIdx,rowIdx];
    interp_value.ColSpan=[2,2];
    interp_value.DialogRefresh=true;

    isLinearInterp=strcmp(h.InterpMethod,'Linear point-slope')||...
    strcmp(h.InterpMethod,'Linear Lagrange');

    rowIdx=rowIdx+1;

    [extrap_prompt,extrap_value]=create_widget(source,h,'ExtrapMethod',rowIdx,2,2);
    extrap_prompt.RowSpan=[rowIdx,rowIdx];
    extrap_prompt.ColSpan=[1,1];
    extrap_prompt.Enabled=1;
    extrap_prompt.Visible=1;


    extrap_value.RowSpan=[rowIdx,rowIdx];
    extrap_value.ColSpan=[2,2];
    extrap_value.Enabled=extrap_value.Enabled&&isLinearInterp;
    extrap_value.Visible=isLinearInterp;
    extrap_value.DialogRefresh=true;

    extrap_box.Name=DAStudio.message('SimulinkBlocks:dialog:Clip_CB');
    extrap_box.Type='text';
    extrap_box.RowSpan=[rowIdx,rowIdx];
    extrap_box.ColSpan=[2,2];
    extrap_box.Enabled=~extrap_value.Enabled;
    extrap_box.Visible=~extrap_value.Enabled;


    enableLastIndex=~isLinearInterp||strcmp(h.ExtrapMethod,'Clip');




    validIdxVal=create_widget(source,h,'ValidIndexMayReachLast',rowIdx,2,2);
    validIdxVal.Enabled=validIdxVal.Enabled&&enableLastIndex;
    validIdxVal.Visible=enableLastIndex;
    validIdxVal.RowSpan=[rowIdx,rowIdx];
    validIdxVal.ColSpan=[3,maxCols];

    rowIdx=rowIdx+1;

    [rangeErr_prompt,rangeErr_value]=create_widget(source,h,'DiagnosticForOutOfRangeInput',rowIdx,2,2);
    rangeErr_prompt.RowSpan=[rowIdx,rowIdx];
    rangeErr_prompt.ColSpan=[1,1];

    rangeErr_value.RowSpan=[rowIdx,rowIdx];
    rangeErr_value.ColSpan=[2,2];

    rowIdx=rowIdx+1;

    selDimValues=create_widget(source,h,'NumSelectionDims',rowIdx,2,2);

    selDimValues.RowSpan=[rowIdx,rowIdx];
    selDimValues.ColSpan=[1,3];

    AlgorithmGroup.Name=DAStudio.message('Simulink:dialog:AlgorithmTab');
    AlgorithmGroup.Type='group';
    AlgorithmGroup.RowSpan=[algGrpStartRowIdx,algGrpStartRowIdx+3];
    AlgorithmGroup.ColSpan=[1,maxCols];
    AlgorithmGroup.LayoutGrid=[7,maxCols];
    AlgorithmGroup.ColStretch=[0,0,0,0,1];

    AlgorithmGroup.Items={interp_prompt,interp_value,extrap_prompt,extrap_box,extrap_value,...
    rangeErr_prompt,rangeErr_value,validIdxVal,selDimValues};

    rowIdx=rowIdx+1;


    cgGrpStartRowIdx=rowIdx;
    checkCodeInRange=create_widget(source,h,'RemoveProtectionIndex',rowIdx,2,2);

    cgGroup.Name=DAStudio.message('Simulink:dialog:GroupCodeGeneration');
    cgGroup.Type='group';
    cgGroup.RowSpan=[cgGrpStartRowIdx,cgGrpStartRowIdx];
    cgGroup.ColSpan=[1,6];
    cgGroup.LayoutGrid=[
    cgGroup.RowSpan(2)-cgGroup.RowSpan(1)+1...
    ,cgGroup.ColSpan(2)-cgGroup.ColSpan(1)+2];
    cgGroup.ColStretch=[ones(1,cgGroup.LayoutGrid(2)-1),6];
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
    spacer.ColSpan=[1,maxCols];

    thisTab.Name=DAStudio.message('Simulink:dialog:ModelTabOneName');

    thisTab.Items={DataGroup,AlgorithmGroup,cgGroup,ts,spacer};

    thisTab.LayoutGrid=[rowIdx,maxCols];
    thisTab.ColStretch=[0,0,0,0,1];
    thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];

end


function[DataGroup,layoutRow]=get_LUTObjectDialogs(source,h,layoutRow,DataGroup)


    [dataSpecificationPrompt,dataSpecification]=create_widget(source,h,'TableSpecification',layoutRow+1,1,1);

    dataSpecificationPrompt.Type='text';
    dataSpecificationPrompt.Visible=true;
    dataSpecificationPrompt.Enabled=true;
    dataSpecificationPrompt.RowSpan=[layoutRow,layoutRow];
    dataSpecificationPrompt.ColSpan=[1,1];
    dataSpecification.Visible=true;
    dataSpecification.Enabled=true&&~source.isHierarchySimulating;
    dataSpecification.DialogRefresh=true;
    dataSpecification.ColSpan=[1,1];

    isLookupTableObject=strcmp(h.TableSpecification,'Lookup table object');


    [lutObjectPrompt,lutObject]=create_widget(source,h,'LookupTableObject',...
    layoutRow+1,1,1);
    lutObjectPrompt.Visible=isLookupTableObject;
    lutObjectPrompt.Enabled=isLookupTableObject;
    lutObjectPrompt.RowSpan=[layoutRow,layoutRow];
    lutObjectPrompt.ColSpan=[2,2];
    lutObject.Visible=isLookupTableObject;
    lutObject.Enabled=isLookupTableObject;
    lutObject.DialogRefresh=true;
    lutObject.ColSpan=[2,5];

    DataGroup.Items={DataGroup.Items{1:end},dataSpecificationPrompt...
    ,dataSpecification,lutObjectPrompt,lutObject};
end


function[DataGroup,rowIdx]=create_table(source,h,rowIdx,maxCols,DataGroup,isLUTObjectFormat)

    valueLabel.Name=DAStudio.message('Simulink:blkprm_prompts:ParamValueLabelId');
    valueLabel.ColSpan=[3,3];
    valueLabel.Tag='Table_Prompt_Tag';
    valueLabel.Buddy='Table';
    valueLabel.RowSpan=[rowIdx,rowIdx];
    valueLabel.Type='text';
    valueLabel.Visible=~isLUTObjectFormat;
    valueLabel.Enabled=~isLUTObjectFormat;

    rowIdx=rowIdx+1;

    tableValues=create_widget(source,h,'Table',rowIdx,2,2);

    [tblSrcPrompt,tableSource]=create_widget(source,h,'TableSource',rowIdx,2,2);
    tblSrcPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:ParamSourceLabelId');
    tblSrcPrompt.RowSpan=[rowIdx-1,rowIdx-1];
    tblSrcPrompt.ColSpan=[2,2];
    tblSrcPrompt.Visible=~isLUTObjectFormat;
    tblSrcPrompt.Enabled=~isLUTObjectFormat;

    tableSource.RowSpan=[rowIdx,rowIdx];
    tableSource.ColSpan=[2,2];
    tableSource.DialogRefresh=true;
    tableSource.Visible=~isLUTObjectFormat;
    tableSource.Enabled=~isLUTObjectFormat;

    if isempty(h.TableSource)

        wasDirty=get_param(bdroot(h.Handle),'Dirty');
        h.TableSource='Dialog';
        set_param(bdroot(h.Handle),'Dirty',wasDirty);
    end

    tableFromDialog=isLUTObjectFormat||strcmp(h.TableSource,'Dialog');



    if tableFromDialog
        tableValues.Enabled=true&&~isLUTObjectFormat;
        tableValues.Visible=true&&~isLUTObjectFormat;
    else
        tableValues='';
        tableValues.Type='edit';
        tableValues.Enabled=false&&~isLUTObjectFormat;
        tableValues.Visible=true&&~isLUTObjectFormat;
    end
    tableValues.Name='';
    tableValues.RowSpan=[rowIdx,rowIdx];
    if isLUTObjectFormat
        tableValues.ColSpan=[4,5];
    else
        tableValues.ColSpan=[3,5];
    end

    tableValuesEdit.Name=DAStudio.message('Simulink:dialog:Editing');
    tableValuesEdit.Type='pushbutton';
    tableValuesEdit.RowSpan=[rowIdx,rowIdx];

    tableValuesEdit.ColSpan=[maxCols,maxCols];
    tableValuesEdit.MatlabMethod='luteditorddg_cb';
    tableValuesEdit.MatlabArgs={'%dialog',h};
    tableValuesEdit.Enabled=tableFromDialog;

    rowIdx=rowIdx+1;
    DataGroup.Items={DataGroup.Items{1:end},valueLabel,tblSrcPrompt,tableSource,tableValues,tableValuesEdit};

end


function thisTab=get_data_type_tab(source,h)





    tableFromDialog=strcmp(h.TableSource,'Dialog');
    isLinearPointslopeInterp=strcmp(h.InterpMethod,'Linear point-slope');

    if(isLookupTableObjectFormat(h))
        if(isLinearPointslopeInterp)
            paramList=[1,2];
        else
            paramList=2;
        end
    else
        if(tableFromDialog)
            if(isLinearPointslopeInterp)
                paramList=[0,1,2];
            else
                paramList=[0,2];
            end
        else
            if(isLinearPointslopeInterp)
                paramList=[1,2];
            else
                paramList=2;
            end
        end
    end

    numParam=length(paramList);

    udtSpecs=cell(1,numParam);
    for paramIdx=1:numParam
        udtSpecs{paramIdx}=get_data_type_specs(source,h,paramList(paramIdx));
    end

    [orderedWidgets,maxRows,maxCols]=lut_create_data_type_widgets(source,h,udtSpecs);

    rowIdx=maxRows+1;

    isNotLinearLagrange=~strcmp(h.InterpMethod,'Linear Lagrange');


    [irPriority_Prompt,irPriority_Value]=create_widget(source,h,'InternalRulePriority',rowIdx,2,2);
    irPriority_Prompt.RowSpan=[rowIdx,rowIdx];
    irPriority_Prompt.ColSpan=[1,1];

    irPriority_Value.RowSpan=[rowIdx,rowIdx];
    irPriority_Value.ColSpan=[2,2];
















    if isNotLinearLagrange
        showIrPriority=true;
    else
        showIrPriority=false;
    end

    irPriority_Prompt.Visible=showIrPriority;
    irPriority_Prompt.Enabled=showIrPriority;
    irPriority_Value.Visible=showIrPriority;
    irPriority_Value.Enabled=showIrPriority;


    rowIdx=rowIdx+1;

    lockOutScale=create_widget(source,h,'LockScale',rowIdx,2,2);
    lockOutScale.RowSpan=[rowIdx,rowIdx];
    lockOutScale.ColSpan=[1,maxCols];



    rowIdx=rowIdx+1;

    round=create_widget(source,h,'RndMeth',rowIdx,2,2);
    round.RowSpan=[rowIdx,rowIdx];
    round.ColSpan=[1,2];
    round.Editable=0;



    rowIdx=rowIdx+1;

    saturate=create_widget(source,h,'SaturateOnIntegerOverflow',rowIdx,2,2);
    saturate.RowSpan=[rowIdx,rowIdx];
    saturate.ColSpan=[1,2];
    saturate.Editable=1;



    rowIdx=rowIdx+1;

    spacer.Name='';

    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,maxCols];

    thisTab.Items=[...
    orderedWidgets,...
    {irPriority_Prompt...
    ,irPriority_Value...
    ,lockOutScale,...
    round,...
    saturate,...
spacer...
    }];

    thisTab.Name=DAStudio.message('Simulink:dialog:DataTypesTab');
    thisTab.LayoutGrid=[rowIdx,maxCols+1];
    thisTab.ColStretch=[0,1,1,1,1,0];
    thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];


end


function dataTypeSpec=get_data_type_specs(source,h,paramNumber)




    switch(paramNumber)
    case 0
        paramPrefix='Table';
        promptString=h.IntrinsicDialogParameters.Table.Prompt;
        scalingModesSelect='BPt_SB_Best';
        inheritRulesSelect='Out_TD';
        builtinSelect='Num';
        scalingValues={'Table'};
        useMinMax=true;
    case 1
        paramPrefix='IntermediateResults';
        promptString=DAStudio.message('Simulink:dialog:IntermediateTypePrompt');
        scalingModesSelect='BPt_SB';
        inheritRulesSelect='IR_Out_TDT';
        builtinSelect='Num';
        scalingValues={};
        useMinMax=false;
    case 2
        paramPrefix='Out';
        promptString=DAStudio.message('Simulink:dialog:OutputTypePrompt');
        scalingModesSelect='BPt_SB_Best';
        inheritRulesSelect='BP_TD2';
        builtinSelect='Num';
        scalingValues={'Table'};
        useMinMax=true;
    end

    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList(scalingModesSelect);
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList(inheritRulesSelect);
    dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList(builtinSelect);
    dataTypeItems.scalingValueTags=scalingValues;

    if useMinMax
        dataTypeItems.scalingMinTag={[paramPrefix,'Min']};
        dataTypeItems.scalingMaxTag={[paramPrefix,'Max']};
    else
        dataTypeItems.scalingMinTag={};
        dataTypeItems.scalingMaxTag={};
    end

    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');

    paramName=[paramPrefix,'DataTypeStr'];

    dataTypeSpec.hDlgSource=source;
    dataTypeSpec.dtName=paramName;
    dataTypeSpec.dtPrompt=promptString;
    dataTypeSpec.dtTag=paramName;
    dataTypeSpec.dtVal=h.(paramName);
    dataTypeSpec.customAsstName=false;
    dataTypeSpec.dtaItems=dataTypeItems;

end


function isLUTObj=isLookupTableObjectFormat(h)
    isLUTObj=strcmp(h.TableSpecification,'Lookup table object');
end
