function dlgStruct=direct_lookupnd_ddg(source,h)







    tableTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB_Best');
    tableTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    tableTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList('NumHalfBool');
    tableTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('In_TD');


    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;


    descGrp.Name='Direct Lookup Table (n-D)';
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    layoutRow=0;
    layoutPrompt=2;
    layoutValue=3;
    layoutCols=layoutPrompt+layoutValue;


    layoutRow=layoutRow+1;
    [numDimPrompt,numDimValue]=start_property(source,h,'NumberOfTableDimensions',...
    layoutRow,layoutPrompt,layoutValue);
    numDimValue.Type='combobox';
    numDimValue.Entries={'1','2','3','4'};
    numDimValue.Editable=1;

    if slfeature('SLDirectLUTBlockRowMajorAlgorithm')>0

        layoutRow=layoutRow+1;
        tableAsInputValue=start_property(source,h,'TableIsInput',...
        layoutRow,layoutPrompt,layoutValue);
        tableAsInputValue.DialogRefresh=true;

        layoutRow=layoutRow+1;
        [tablePrompt]=start_property(source,h,'Table',...
        layoutRow,layoutPrompt,layoutValue-1);


        tableValuesEdit.Name=DAStudio.message('Simulink:dialog:Editing');
        tableValuesEdit.Type='pushbutton';
        tableValuesEdit.RowSpan=[layoutRow,layoutRow];
        tableValuesEdit.ColSpan=[layoutCols,layoutCols];
        tableValuesEdit.MatlabMethod='luteditorddg_cb';
        tableValuesEdit.MatlabArgs={'%dialog',h};

        if(strcmp(h.TableIsInput,'on'))
            tablePrompt.Visible=false;
            tablePrompt.Enabled=false;
            tableValuesEdit.Visible=false;
            tableValuesEdit.Enabled=false;
        else

            tablePrompt.Visible=true;
            tablePrompt.Enabled=true;
            tableValuesEdit.Visible=true;
            tableValuesEdit.Enabled=true;
        end






        DataGroup.Name=DAStudio.message('Simulink:blkprm_prompts:TableGroupLabelId');
        DataGroup.Type='group';
        DataGroup.RowSpan=[1,3];
        DataGroup.ColSpan=[1,layoutCols];
        DataGroup.LayoutGrid=[3,layoutCols];
        DataGroup.ColStretch=[0,0,1,1,0];
        DataGroup.Items={numDimPrompt,numDimValue,tableAsInputValue,tablePrompt,tableValuesEdit};

        layoutRow=layoutRow+1;
        algGrpStartRowIdx=layoutRow;

        [outputDimsPrompt,...
        outputDimsValue]=start_property(source,h,'InputsSelectThisObjectFromTable',...
        layoutRow,layoutPrompt,layoutValue);


        layoutRow=layoutRow+1;
        [rangeErrPrompt,rangeErr_popup]=start_property(source,h,'DiagnosticForOutOfRangeInput',...
        layoutRow,layoutPrompt,layoutValue);





        AlgorithmGroup.Name=DAStudio.message('Simulink:dialog:AlgorithmTab');
        AlgorithmGroup.Type='group';
        AlgorithmGroup.RowSpan=[algGrpStartRowIdx,algGrpStartRowIdx+1];
        AlgorithmGroup.ColSpan=[1,layoutCols];
        AlgorithmGroup.LayoutGrid=[6,layoutCols];
        AlgorithmGroup.ColStretch=[0,0,0,0,1];

        AlgorithmGroup.Items={outputDimsPrompt,outputDimsValue,...
        rangeErrPrompt,rangeErr_popup};
    else

        layoutRow=layoutRow+1;
        [outputDimsPrompt,...
        outputDimsValue]=start_property(source,h,'InputsSelectThisObjectFromTable',...
        layoutRow,layoutPrompt,layoutValue);
        layoutRow=layoutRow+1;
        tableAsInputValue=start_property(source,h,'TableIsInput',...
        layoutRow,layoutPrompt,layoutValue);
        tableAsInputValue.DialogRefresh=true;

        layoutRow=layoutRow+1;
        [tablePrompt]=start_property(source,h,'Table',...
        layoutRow,layoutPrompt,layoutValue-1);


        tableValuesEdit.Name=DAStudio.message('Simulink:dialog:Editing');
        tableValuesEdit.Type='pushbutton';
        tableValuesEdit.RowSpan=[layoutRow,layoutRow];
        tableValuesEdit.ColSpan=[layoutCols,layoutCols];
        tableValuesEdit.MatlabMethod='luteditorddg_cb';
        tableValuesEdit.MatlabArgs={'%dialog',h};

        if(strcmp(h.TableIsInput,'on'))
            tablePrompt.Visible=false;
            tablePrompt.Enabled=false;
            tableValuesEdit.Visible=false;
            tableValuesEdit.Enabled=false;
        else

            tablePrompt.Visible=true;
            tablePrompt.Enabled=true;
            tableValuesEdit.Visible=true;
            tableValuesEdit.Enabled=true;
        end

        layoutRow=layoutRow+1;
        [rangeErrPrompt,rangeErr_popup]=start_property(source,h,'DiagnosticForOutOfRangeInput',...
        layoutRow,layoutPrompt,layoutValue);

    end




    layoutRow=layoutRow+1;
    checkRangeInCode=create_widget(source,h,'RemoveProtectionInput',...
    layoutRow,layoutPrompt,layoutValue);


    cgGroup.Name=DAStudio.message('Simulink:dialog:GroupCodeGeneration');
    cgGroup.Type='group';
    cgGroup.RowSpan=[checkRangeInCode.RowSpan(1),checkRangeInCode.RowSpan(2)];
    cgGroup.ColSpan=[1,layoutCols];
    cgGroup.LayoutGrid=[
    cgGroup.RowSpan(2)-cgGroup.RowSpan(1)+1...
    ,cgGroup.ColSpan(2)-cgGroup.ColSpan(1)];
    cgGroup.ColStretch=[ones(1,cgGroup.LayoutGrid(2)-1),6];
    rowOffset=checkRangeInCode.RowSpan(1)-1;
    checkRangeInCode.RowSpan=checkRangeInCode.RowSpan-rowOffset;
    cgGroup.Items={checkRangeInCode};



    layoutRow=layoutRow+1;
    if slfeature('HideSampleTimeWidgetWithDefaultValue')>0
        ts=Simulink.SampleTimeWidget.getCustomDdgWidget(...
        source,h,'SampleTime','',layoutRow,layoutCols,1);
        ts.RowSpan=[layoutRow,layoutRow];
        ts.ColSpan=[1,layoutCols];
    else
        [tsPrompt,tsValue]=start_property(source,h,'SampleTime',...
        layoutRow,layoutPrompt,layoutValue);
    end

    layoutRow=layoutRow+1;
    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[layoutRow,layoutRow];
    spacer.ColSpan=[1,layoutCols];

    mainTab.Name=DAStudio.message('Simulink:dialog:ModelTabOneName');
    if slfeature('HideSampleTimeWidgetWithDefaultValue')>0||...
        slfeature('EnableAdvancedSampleTimeWidget')>0

        if slfeature('SLDirectLUTBlockRowMajorAlgorithm')>0
            mainTab.Items={...
...
            DataGroup,...
            AlgorithmGroup,...
            cgGroup,...
ts...
            ,spacer};

        else
            mainTab.Items={...
...
            numDimPrompt,numDimValue...
            ,outputDimsPrompt,outputDimsValue...
            ,tableAsInputValue...
            ,tablePrompt,tableValuesEdit...
            ,rangeErrPrompt,rangeErr_popup...
            ,ts...
            ,spacer};
        end

    else
        if slfeature('SLDirectLUTBlockRowMajorAlgorithm')>0

            mainTab.Items={...
...
            DataGroup,...
            AlgorithmGroup,...
            cgGroup,...
            tsPrompt,tsValue...
            ,spacer};
        else
            mainTab.Items={...
...
            numDimPrompt,numDimValue...
            ,outputDimsPrompt,outputDimsValue...
            ,tableAsInputValue...
            ,tablePrompt,tableValuesEdit...
            ,rangeErrPrompt,rangeErr_popup...
            ,tsPrompt,tsValue...
            ,spacer};
        end
    end

    mainTab.LayoutGrid=[layoutRow,layoutCols];
    mainTab.ColStretch=[ones(1,mainTab.LayoutGrid(2)-1),0];
    mainTab.RowStretch=[zeros(1,mainTab.LayoutGrid(1)-1),1];



    layoutRow=1;
    layoutPrompt=2;
    layoutValue=2;
    layoutCols=layoutPrompt+layoutValue;
    layoutStartPrompt=1;

    [tableMinPrompt,tableMin]=start_property(source,h,'TableMin',layoutRow,...
    1,1,layoutStartPrompt);

    [tableMaxPrompt,tableMax]=start_property(source,h,'TableMax',layoutRow,...
    layoutPrompt+1,1,layoutStartPrompt+layoutValue);

    tableTypeItems.scalingMinTag={tableMin.Tag};
    tableTypeItems.scalingMaxTag={tableMax.Tag};
    tableTypeItems.scalingValueTags={tablePrompt.Tag};
    tableTypeItems.supportsEnumType=true;

    paramName='TableDataTypeStr';




    tableTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
    paramName,...
    h.IntrinsicDialogParameters.(paramName).Prompt,...
    paramName,...
    h.(paramName),...
    tableTypeItems,...
    false);
    layoutRow=layoutRow+1;

    tableTypeGroup.RowSpan=[layoutRow,layoutRow];
    tableTypeGroup.ColSpan=[1,4];

    layoutRow=layoutRow+1;
    lockOutScaleValue=start_property(source,h,'LockScale',...
    layoutRow,layoutPrompt,layoutValue);

    if(strcmp(h.TableIsInput,'on'))
        tableMinPrompt.Enabled=false;
        tableMin.Enabled=false;
        tableMaxPrompt.Enabled=false;
        tableMax.Enabled=false;
        tableTypeGroup.Enabled=false;
        lockOutScaleValue.Enabled=false;
    else
        tableMinPrompt.Enabled=~source.isHierarchySimulating;
        tableMin.Enabled=~source.isHierarchySimulating;
        tableMaxPrompt.Enabled=~source.isHierarchySimulating;
        tableMax.Enabled=~source.isHierarchySimulating;
        tableTypeGroup.Enabled=~source.isHierarchySimulating;
        lockOutScaleValue.Enabled=~source.isHierarchySimulating;
    end

    layoutRow=layoutRow+1;

    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[layoutRow,layoutRow];
    spacer.ColSpan=[1,4];

    tableTab.Items={tableMinPrompt,tableMin,...
    tableMaxPrompt,tableMax,...
    tableTypeGroup,lockOutScaleValue,spacer};
    tableTab.Name=DAStudio.message('Simulink:dialog:TableAttributes');
    tableTab.LayoutGrid=[layoutRow,layoutCols];
    tableTab.RowStretch=[zeros(1,tableTab.LayoutGrid(1)-1),1];

    if(strcmp(h.TableIsInput,'on'))

        tableAttribHiddenPrompt.Name=DAStudio.message('Simulink:dialog:TableAttributesHiddenPrompt');
        tableAttribHiddenPrompt.Type='text';
        tableAttribHiddenPrompt.RowSpan=[2,2];
        tableAttribHiddenPrompt.ColSpan=[1,4];
        tableTab.Items={tableAttribHiddenPrompt,spacer};
    end


    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='tab';
    paramGrp.Tabs={mainTab,tableTab};
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;




    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,newline,' ')));
    dlgStruct.DialogTag='LookupNDDirect';
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


function[out1,out2]=start_property(source,h,propName,...
    layoutRow,layoutPrompt,layoutValue,layoutStartPrompt)








    if nargout==1

        prompt='out1';
        value='out1';
    else

        prompt='out1';
        value='out2';
        temp.out1.Type='text';
    end

    if nargin<=6

        layoutStartPrompt=1;
    end


    temp.(value).ObjectProperty=propName;
    temp.(value).Tag=temp.(value).ObjectProperty;

    temp.(prompt).Name=h.IntrinsicDialogParameters.(propName).Prompt;

    switch lower(h.IntrinsicDialogParameters.(propName).Type)
    case 'enum'
        temp.(value).Type='combobox';
        temp.(value).Entries=h.getPropAllowedValues(propName,true)';
        temp.(value).MatlabMethod='handleComboSelectionEvent';
        temp.(value).Editable=0;
    case 'boolean'
        temp.(value).Type='checkbox';
        temp.(value).MatlabMethod='handleCheckEvent';
    otherwise
        temp.(value).Type='edit';
        temp.(value).MatlabMethod='handleEditEvent';
    end

    temp.(value).MatlabArgs={source,'%value',find(strcmp(source.paramsMap,propName))-1,'%dialog'};

    if~h.isTunableProperty(propName)
        temp.(value).Enabled=~source.isHierarchySimulating;
    end

    out1=temp.out1;
    out1.RowSpan=[layoutRow,layoutRow];

    if nargout>1
        out2=temp.out2;
        out2.RowSpan=[layoutRow,layoutRow];
        out1.ColSpan=[layoutStartPrompt,layoutPrompt];
        out2.ColSpan=[(layoutPrompt+1),(layoutPrompt+layoutValue)];
        out1.Tag=[out2.ObjectProperty,'_Prompt_Tag'];
        out1.Buddy=out2.Tag;
    else
        out1.ColSpan=[layoutStartPrompt,(layoutPrompt+layoutValue)];
    end

end
