function dlgStruct=sqrt_ddg(source,h)









    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];
    isNotSimulating=~source.isHierarchySimulating;

    isRSqrt=strcmp(h.Operator,'rSqrt');
    isSSqrt=strcmp(h.Operator,'signedSqrt');

    funcSource=start_property(source,h,'Operator');
    funcSource.RowSpan=[1,1];
    funcSource.ColSpan=[1,2];
    funcSource.Editable=0;
    funcSource.Enabled=isNotSimulating;



    funcSource.DialogRefresh=true;
    funcSource.ToolTip=DAStudio.message('SimulinkBlocks:SqrtFcn:sqrtDlgFunction');


    [outSignalTypePrompt,outSignalTypeValue]=create_widget(source,h,'OutputSignalType',...
    2,1,2);


    outSignalTypePrompt.RowSpan=[2,2];
    outSignalTypePrompt.ColSpan=[1,1];
    outSignalTypePrompt.ToolTip=DAStudio.message('SimulinkBlocks:SqrtFcn:sqrtDlgOutSignalType');


    outSignalTypeValue.RowSpan=[2,2];
    outSignalTypeValue.ColSpan=[2,2];
    outSignalTypeValue.Visible=~isRSqrt;
    outSignalTypeValue.Enabled=(isNotSimulating&&~isRSqrt);


    outSignalTypeReal.Name=DAStudio.message('SimulinkBlocks:dialog:real_CB');
    outSignalTypeReal.Type='text';
    outSignalTypeReal.RowSpan=[2,2];
    outSignalTypeReal.ColSpan=[2,2];
    outSignalTypeReal.Visible=isRSqrt;
    outSignalTypeReal.Enabled=isRSqrt;

    ts=Simulink.SampleTimeWidget.getCustomDdgWidget(...
    source,h,'SampleTime','',3,2,2,false);
    ts.RowSpan=[3,3];
    ts.ColSpan=[1,2];

    bottomSpacer1.Name='';
    bottomSpacer1.Type='text';
    bottomSpacer1.RowSpan=[4,4];
    bottomSpacer1.ColSpan=[1,2];



    mainTab.Name=DAStudio.message('Simulink:dialog:Main');
    mainTab.Items={...
funcSource...
    ,outSignalTypePrompt...
    ,outSignalTypeReal...
    ,outSignalTypeValue...
    ,ts...
    ,bottomSpacer1};

    numRow=4;
    numCol=4;
    mainTab.LayoutGrid=[numRow,numCol];
    mainTab.ColStretch=[0,ones(1,numCol-2),0];
    mainTab.RowStretch=[zeros(1,numRow-1),1];



    IntermAttributes.Name=DAStudio.message('Simulink:dialog:AlgorithmTab');




    [MethodSourcePrompt,MethodSourceValue]=create_widget(source,h,'AlgorithmType',...
    1,1,2);


    MethodSourcePrompt.RowSpan=[1,1];
    MethodSourcePrompt.ColSpan=[1,1];
    MethodSourcePrompt.ToolTip=DAStudio.message('SimulinkBlocks:SqrtFcn:sqrtDlgMethod');


    MethodSourceValue.RowSpan=[1,1];
    MethodSourceValue.ColSpan=[2,2];
    MethodSourceValue.Visible=isRSqrt;
    MethodSourceValue.Enabled=(isNotSimulating&&isRSqrt);



    MethodSourcePrompt.DialogRefresh=true;


    MethodSourceExact.Name=DAStudio.message('SimulinkBlocks:dialog:Exact_CB');
    MethodSourceExact.Type='text';
    MethodSourceExact.RowSpan=[1,1];
    MethodSourceExact.ColSpan=[2,2];
    MethodSourceExact.Visible=~isRSqrt;
    MethodSourceExact.Enabled=~isRSqrt;

    isNR=strcmp(h.AlgorithmType,'Newton-Raphson');


    NumIterations=start_property(source,h,'Iterations');
    NumIterations.RowSpan=[2,2];
    NumIterations.ColSpan=[1,2];
    NumIterations.Visible=isRSqrt&&isNR;
    NumIterations.Enabled=(isNotSimulating&&isRSqrt&&isNR);
    NumIterations.Editable=NumIterations.Enabled;
    NumIterations.ToolTip=DAStudio.message('SimulinkBlocks:SqrtFcn:sqrtDlgNumIterations');

    bottomSpacer3.Name='';
    bottomSpacer3.Type='text';
    bottomSpacer3.RowSpan=[3,3];
    bottomSpacer3.ColSpan=[1,2];

    IntermAttributes.Items={MethodSourcePrompt,MethodSourceExact,...
    MethodSourceValue,NumIterations,bottomSpacer3};


    numRow=3;
    numCol=4;
    IntermAttributes.LayoutGrid=[numRow,numCol];
    IntermAttributes.ColStretch=[0,ones(1,numCol-2),0];
    IntermAttributes.RowStretch=[zeros(1,numRow-1),1];


    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='tab';
    paramGrp.Tabs={mainTab,IntermAttributes,get_data_type_tab(source,h,isSSqrt)};

    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;




    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.DialogTag='Sqrt';
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


function property=start_property(source,h,propName)



    property.ObjectProperty=propName;
    property.Tag=property.ObjectProperty;

    property.Name=h.IntrinsicDialogParameters.(propName).Prompt;

    property.Visible=1;


    switch lower(h.IntrinsicDialogParameters.(propName).Type)
    case 'enum'
        property.Type='combobox';
        property.Entries=h.getPropAllowedValues(propName,true)';
        property.MatlabMethod='handleComboSelectionEvent';
    case 'boolean'
        property.Type='checkbox';
        property.MatlabMethod='handleCheckEvent';
    otherwise
        property.Type='edit';
        property.MatlabMethod='handleEditEvent';
    end

    property.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};

end

function thisTab=get_data_type_tab(source,h,isSSqrt)


    numDimsToUse=2;


    udtSpecs=cell(1,numDimsToUse);

    for paramIdx=1:2
        udtSpecs{paramIdx}=get_data_type_specs(source,h,paramIdx);
    end

    [orderedWidgets,maxRows,maxCols]=sqrt_create_data_type_widgets(source,h,udtSpecs,isSSqrt);

    isNotSimulating=~source.isHierarchySimulating;
    rowIdx=maxRows+1;
    lockOutScale=start_property(source,h,'LockScale');
    rowIdx=rowIdx+1;
    lockOutScale.RowSpan=[rowIdx,rowIdx];
    lockOutScale.ColSpan=[1,2];

    lockOutScale.MatlabMethod='slDDGUtil';
    lockOutScale.MatlabArgs={source,'sync','%dialog','checkbox','%tag','%value'};
    lockOutScale.Enabled=isNotSimulating;

    round=start_property(source,h,'RndMeth');
    rowIdx=rowIdx+1;
    round.RowSpan=[rowIdx,rowIdx];
    round.ColSpan=[1,2];
    round.Editable=0;
    round.MatlabMethod='slDDGUtil';
    round.MatlabArgs={source,'sync','%dialog','combobox','%tag','%value'};
    round.Enabled=isNotSimulating;

    saturate=start_property(source,h,'SaturateOnIntegerOverflow');
    rowIdx=rowIdx+1;
    saturate.RowSpan=[rowIdx,rowIdx];
    saturate.ColSpan=[1,2];
    saturate.Editable=1;
    saturate.Enabled=isNotSimulating;

    bottomSpacer2.Name='';
    rowIdx=rowIdx+1;
    bottomSpacer2.Type='text';
    bottomSpacer2.RowSpan=[rowIdx,rowIdx];
    bottomSpacer2.ColSpan=[1,2];


    thisTab.Items=[...
orderedWidgets...
    ,{lockOutScale...
    ,round...
    ,saturate...
    ,bottomSpacer2...
    }];

    thisTab.Name=DAStudio.message('Simulink:dialog:DataTypesTab');
    thisTab.LayoutGrid=[rowIdx,maxCols+1];
    thisTab.ColStretch=[0,1,1,1,1,0];
    thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];


end

function dataTypeSpec=get_data_type_specs(source,h,paramNumber)


    if paramNumber==1
        paramPrefix='IntermediateResults';
        promptString=DAStudio.message('Simulink:dialog:IntermediateTypePrompt');
        useMinMax=false;
        dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
        dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
        dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('Num');
        dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('In_RSqrt');
    elseif paramNumber==2
        paramPrefix='Out';
        promptString=DAStudio.message('Simulink:dialog:OutputTypePrompt');
        dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
        dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
        dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('NumHalf');
        dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('In_Sqrt');
        useMinMax=true;
    end

    paramName=[paramPrefix,'DataTypeStr'];

    dataTypeItems.scalingValueTags={};
    if useMinMax
        dataTypeItems.scalingMinTag={[paramPrefix,'Min']};
        dataTypeItems.scalingMaxTag={[paramPrefix,'Max']};
    else
        dataTypeItems.scalingMinTag={};
        dataTypeItems.scalingMaxTag={};
    end

    dataTypeSpec.hDlgSource=source;
    dataTypeSpec.dtName=paramName;
    dataTypeSpec.dtPrompt=promptString;
    dataTypeSpec.dtTag=paramName;
    dataTypeSpec.dtVal=h.(paramName);
    dataTypeSpec.customAsstName=false;
    dataTypeSpec.dtaItems=dataTypeItems;

end


function[dtWidget,maxRows,maxCols]=sqrt_create_data_type_widgets(source,h,udtSpecs,isSSqrt)

    maxCols=5;
    colIdxCell=num2cell(1:maxCols);


    [dtaPrmColIdx,dtaUDTColIdx,dtaBtnColIdx,desMinColIdx,desMaxColIdx]=deal(colIdxCell{:});

    rowIdx=1;


    columnHeaders={...
    create_data_type_header('SimulinkBlocks:SqrtFcn:SqrtDataTypesHeaderDT',rowIdx,dtaUDTColIdx,dtaBtnColIdx-1)...
    ,create_data_type_header('SimulinkBlocks:SqrtFcn:SqrtDataTypesHeaderAsst',rowIdx,dtaBtnColIdx)...
    ,create_data_type_header('SimulinkBlocks:SqrtFcn:SqrtDataTypesHeaderMin',rowIdx,desMinColIdx)...
    ,create_data_type_header('SimulinkBlocks:SqrtFcn:SqrtDataTypesHeaderMax',rowIdx,desMaxColIdx)...
    };

    totalHeaders=length(columnHeaders);

    [promptWidgets,comboxWidgets,shwBtnWidgets,hdeBtnWidgets,dtaGUIWidgets]=...
    Simulink.DataTypePrmWidget.getSPCDataTypeWidgets(source,udtSpecs,-1,...
    []);

    totalParam=length(udtSpecs);

    totalParamWithMinMax=0;
    for paramIdx=1:totalParam
        if~isempty(udtSpecs{paramIdx}.dtaItems.scalingMinTag)
            totalParamWithMinMax=totalParamWithMinMax+1;
        end
    end


    desMinWidgets=cell(1,totalParamWithMinMax);
    desMaxWidgets=cell(1,totalParamWithMinMax);






    totalWidgetTableCount=totalParam*5+totalParamWithMinMax*2;

    orderedWidgets=cell(1,totalWidgetTableCount+totalHeaders);

    for headerIdx=1:totalHeaders
        orderedWidgets{headerIdx}=columnHeaders{headerIdx};
    end

    currentInsertWidget=totalHeaders;
    minMaxIdx=1;

    isNotSimulating=~source.isHierarchySimulating;

    for paramIdx=1:totalParam

        rowIdx=rowIdx+1;


        promptWidgets{paramIdx}.RowSpan=[rowIdx,rowIdx];
        promptWidgets{paramIdx}.ColSpan=[dtaPrmColIdx,dtaUDTColIdx-1];
        promptWidgets{paramIdx}.Enabled=1;

        currentInsertWidget=currentInsertWidget+1;
        orderedWidgets{currentInsertWidget}=promptWidgets{paramIdx};


        comboxWidgets{paramIdx}.RowSpan=[rowIdx,rowIdx];
        comboxWidgets{paramIdx}.ColSpan=[dtaUDTColIdx,dtaBtnColIdx-1];


        if paramIdx==1

            if isSSqrt

                InheritViaInternalRuleValue.Name=DAStudio.message(...
                'SimulinkBlocks:SqrtFcn:sqrtDlgIntermediateDTValueInheritViaInternalRule');
                InheritViaInternalRuleValue.Type='text';
                InheritViaInternalRuleValue.RowSpan=[2,2];
                InheritViaInternalRuleValue.ColSpan=[2,2];
                InheritViaInternalRuleValue.Visible=isSSqrt;
                InheritViaInternalRuleValue.Enabled=isSSqrt;


                currentInsertWidget=currentInsertWidget+1;
                orderedWidgets{currentInsertWidget}=InheritViaInternalRuleValue;
            else

                comboxWidgets{paramIdx}.Enabled=isNotSimulating&&~isSSqrt;
                comboxWidgets{paramIdx}.Visible=~isSSqrt;


                currentInsertWidget=currentInsertWidget+1;
                orderedWidgets{currentInsertWidget}=comboxWidgets{paramIdx};
            end

        else

            comboxWidgets{paramIdx}.Enabled=isNotSimulating;

            currentInsertWidget=currentInsertWidget+1;
            orderedWidgets{currentInsertWidget}=comboxWidgets{paramIdx};
        end



        shwBtnWidgets{paramIdx}.RowSpan=[rowIdx,rowIdx];
        shwBtnWidgets{paramIdx}.ColSpan=[dtaBtnColIdx,dtaBtnColIdx];
        if paramIdx==1
            shwBtnWidgets{paramIdx}.Enabled=isNotSimulating&&~isSSqrt;
        else
            shwBtnWidgets{paramIdx}.Enabled=isNotSimulating;
        end
        shwBtnWidgets{paramIdx}.MaximumSize=get_size('BtnMax');


        currentInsertWidget=currentInsertWidget+1;
        orderedWidgets{currentInsertWidget}=shwBtnWidgets{paramIdx};


        hdeBtnWidgets{paramIdx}.RowSpan=[rowIdx,rowIdx];
        hdeBtnWidgets{paramIdx}.ColSpan=[dtaBtnColIdx,dtaBtnColIdx];
        hdeBtnWidgets{paramIdx}.MaximumSize=get_size('BtnMax');
        hdeBtnWidgets{paramIdx}.Enabled=isNotSimulating;


        currentInsertWidget=currentInsertWidget+1;
        orderedWidgets{currentInsertWidget}=hdeBtnWidgets{paramIdx};

        if~isempty(udtSpecs{paramIdx}.dtaItems.scalingMinTag)
            [~,desMinWidgets{minMaxIdx}]=create_widget(source,h,...
            udtSpecs{paramIdx}.dtaItems.scalingMinTag{1},rowIdx,...
            desMinColIdx-1,desMaxColIdx-desMinColIdx);
            desMinWidgets{minMaxIdx}.MaximumSize=get_size('DesMMMax');
            if strfind(udtSpecs{paramIdx}.dtaItems.scalingMinTag{1},'BreakpointsForDimension')
                desMinWidgets{minMaxIdx}.UserData.detailPrompt=...
                DAStudio.message('Simulink:dialog:BreakPointsMin',paramIdx-1);
            end


            desMinWidgets{minMaxIdx}.Enabled=isNotSimulating;

            currentInsertWidget=currentInsertWidget+1;
            orderedWidgets{currentInsertWidget}=desMinWidgets{minMaxIdx};


            [~,desMaxWidgets{minMaxIdx}]=create_widget(source,h,...
            udtSpecs{paramIdx}.dtaItems.scalingMaxTag{1},rowIdx,...
            desMaxColIdx-1,desMaxColIdx-desMinColIdx);
            desMaxWidgets{minMaxIdx}.MaximumSize=get_size('DesMMMax');

            if strfind(udtSpecs{paramIdx}.dtaItems.scalingMaxTag{1},'BreakpointsForDimension')
                desMaxWidgets{minMaxIdx}.UserData.detailPrompt=...
                DAStudio.message('Simulink:dialog:BreakPointsMax',paramIdx-1);
            end


            desMaxWidgets{minMaxIdx}.Enabled=isNotSimulating;

            currentInsertWidget=currentInsertWidget+1;
            orderedWidgets{currentInsertWidget}=desMaxWidgets{minMaxIdx};

            minMaxIdx=minMaxIdx+1;
        end

        rowIdx=rowIdx+1;
        dtaGUIWidgets{paramIdx}.RowSpan=[rowIdx,rowIdx];
        dtaGUIWidgets{paramIdx}.ColSpan=[2,maxCols];
        dtaGUIWidgets{paramIdx}.Enabled=isNotSimulating;


        currentInsertWidget=currentInsertWidget+1;
        orderedWidgets{currentInsertWidget}=dtaGUIWidgets{paramIdx};

    end

    dtWidget=orderedWidgets;
    maxRows=rowIdx;


    function size=get_size(what)
        switch what
        case 'BtnMax'
            size=[(get_inch*5/12),2^24-1];
        case 'DesMMMax'
            size=[get_inch,2^24-1];
        otherwise
            size=[0,0];
        end
    end

    function dpi=get_inch
        dpi=get(0,'ScreenPixelsPerInch');
    end
end


