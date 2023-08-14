function dlgStruct=getDialogSchema(this,~)
































    this.paramsMap=this.getDialogParams;


    block=this.getBlock;


    try



        this.getHierarchyInfo(block);






        hOpenDialogs=this.retainWidgetStatus;


        descGroup=this.createBlkDescGroup(block);






        InputSpecificationPanel=createInputSpecificationGroup(this,hOpenDialogs);



        isValidationEnabled=strcmp(get_param(block.Handle,'MatchInputsString'),'on');






        signalPanel=createInputGroup(this,hOpenDialogs,isValidationEnabled);
        if isfield(block.UserData,'signalHierarchy')&&...
            (isempty(block.UserData.signalHierarchy))
            signalPanel.Enabled=0;
        end






        OutputDataTypePanel=createDataTypeGroup(this,hOpenDialogs,block);



        invisibleGroup=createInvisibleGroup(this);
        invisibleStringGroup=createInvisibleStringGroup(this);


        paramGroup=this.combineGroups(block,...
        InputSpecificationPanel,...
        signalPanel,...
        OutputDataTypePanel,...
        invisibleGroup,...
        invisibleStringGroup);




        dlgStruct=this.createDialogStruct(block,descGroup,paramGroup);
        dlgStruct.OpenCallback=@initialize;

        if isfield(block.UserData,'signalHierarchy')&&...
            (isempty(block.UserData.signalHierarchy))
            dlgStruct.DisableDialog=true;
        end
    catch ME
        dlgStruct=this.errorDlg(block,ME.message);
    end
end


function[InputSpecificationPanel]=createInputSpecificationGroup(source,hOpenDialog)


    numInEditBox=createNumInEditBox(source);


    InputSpecificationPanel.Type='panel';
    InputSpecificationPanel.Items={numInEditBox};
    InputSpecificationPanel.LayoutGrid=[2,1];
    InputSpecificationPanel.RowSpan=[1,1];
    InputSpecificationPanel.ColSpan=[1,1];
end

function[signalPanel]=createInputGroup(source,hOpenDialog,isValidationEnabled)






    if isempty(source.signalSelector)
        source.createSignalSelector([]);
    end


    sigviewgroup=getDialogSchema(source.signalSelector,'');
    sigviewgroup.Tag='signalSelectorGroup';
    if~isempty(hOpenDialog)
        sigviewgroup.Visible=hOpenDialog.isVisible(sigviewgroup.Tag);
    else
        sigviewgroup.Visible=~isValidationEnabled;
    end


    signalsTree.Name='Bus Hierarchy Viewer';
    signalsTree.Type='panel';
    signalsTree.Items={sigviewgroup};
    signalsTree.RowSpan=[1,1];
    signalsTree.ColSpan=[1,1];
    signalsTree.Source=source.signalSelector;



    signalListGroup=createSignalListGroup(source,hOpenDialog,isValidationEnabled);


    buttonGroup=createButtonGroup(source,hOpenDialog,isValidationEnabled);


    signalPanel.Type='panel';
    signalPanel.Items={signalsTree,signalListGroup,buttonGroup};
    signalPanel.LayoutGrid=[1,2];
    signalPanel.ColStretch=[1,0];
    signalPanel.RowSpan=[2,2];
    signalPanel.ColSpan=[1,1];
end

function[OutputDataTypePanel]=createDataTypeGroup(source,hOpenDialogs,block)







    paramName='OutDataTypeStr';
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList('Auto');
    dataTypeItems.supportsBusType=true;
    dataTypeItems.udtIndex=find(strcmp(paramName,source.getDialogParams),1)-1;
    dataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(source,...
    paramName,...
    getString(message('Simulink:dialog:OutputDataType')),...
    paramName,...
    block.OutDataTypeStr,...
    dataTypeItems,...
    false);
    dataTypeGroup.RowSpan=[1,1];
    dataTypeGroup.ColSpan=[1,2];
    dataTypeGroup.Source=source;


    outputCheckBox=createOutputCheckBox(source);



    inheritCheckBox=createOverrideFromInputsCheckBox(source);
    matchCheckBox=createSignalMatchCheckBox(source);


    if~isempty(hOpenDialogs)
        outputCheckBox.Visible=hOpenDialogs.isVisible(outputCheckBox.Tag);
        inheritCheckBox.Visible=hOpenDialogs.isVisible(inheritCheckBox.Tag);
        matchCheckBox.Visible=hOpenDialogs.isVisible(matchCheckBox.Tag);
    end


    OutputDataTypePanel.Type='panel';
    OutputDataTypePanel.Items={dataTypeGroup,inheritCheckBox,matchCheckBox,outputCheckBox};
    OutputDataTypePanel.LayoutGrid=[4,2];
    OutputDataTypePanel.ColStretch=[1,0];
    OutputDataTypePanel.RowSpan=[3,3];
    OutputDataTypePanel.ColSpan=[1,1];

end

function[inputsInvisible]=createInvisibleGroup(source)


    inputsInvisible.Name='Inputs';
    inputsInvisible.Type='edit';
    inputsInvisible.Value=source.state.Inputs;
    inputsInvisible.Visible=0;
    inputsInvisible.RowSpan=[5,5];
    inputsInvisible.ColSpan=[1,2];
    inputsInvisible.ObjectProperty='Inputs';
    inputsInvisible.Tag=inputsInvisible.ObjectProperty;

end

function[inputsInvisibleString]=createInvisibleStringGroup(source)


    inputsInvisibleString.Name='InputsString';
    inputsInvisibleString.Type='edit';
    inputsInvisibleString.Value=source.state.InputsString;
    inputsInvisibleString.Visible=0;
    inputsInvisibleString.RowSpan=[6,6];
    inputsInvisibleString.ColSpan=[1,2];
    inputsInvisibleString.ObjectProperty='InputsString';
    inputsInvisibleString.Tag=inputsInvisibleString.ObjectProperty;

end


function initialize(dlg)


    block=dlg.getSource.getBlock;
    if isfield(block.UserData,'signalHierarchy')&&...
        isempty(block.UserData.signalHierarchy)
        block.SignalHierarchy;
    end

end

function[inheritCombo]=createInheritComboBox(source,hOpenDialog)



    inheritCombo.Type='combobox';
    inheritCombo.Entries={DAStudio.message('Simulink:dialog:DDGSource_Bus_InheritNames'),...
    DAStudio.message('Simulink:dialog:DDGSource_Bus_RequireMatch')};
    inheritCombo.RowSpan=[1,1];
    inheritCombo.ColSpan=[1,1];
    inheritCombo.Tag='inheritCombo';
    inheritCombo.ObjectMethod='inheritNames';
    inheritCombo.MethodArgs={'%dialog','%tag'};
    inheritCombo.ArgDataTypes={'handle','string'};
    inheritCombo.Source=source;
    if~isempty(hOpenDialog)
        inheritCombo.Value=hOpenDialog.getWidgetValue(inheritCombo.Tag);
    else
        inheritCombo.Value=double(isnan(source.str2doubleNoComma(source.state.Inputs)));
    end
end

function[numInEdit]=createNumInEditBox(source)


    numInEdit.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_NumInputs');
    numInEdit.Type='edit';
    numInEdit.RowSpan=[1,1];
    numInEdit.ColSpan=[1,1];
    numInEdit.Value=source.getNumInputs;
    numInEdit.Tag='numInEdit';
    numInEdit.ObjectMethod='updateInputs';
    numInEdit.MethodArgs={'%dialog','%tag'};
    numInEdit.ArgDataTypes={'handle','string'};
    numInEdit.Source=source;
end

function[signalListPanel]=createSignalListGroup(source,hOpenDialog,isValidationEnabled)




    signalsList.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_SignalsInBus');
    signalsList.Type='listbox';
    signalsList.MultiSelect=0;
    signalsList.Entries=source.getListEntries(source.getBlock);
    signalsList.UserData=signalsList.Entries;
    signalsList.RowSpan=[1,1];
    signalsList.ColSpan=[1,1];
    signalsList.MinimumSize=[200,200];
    signalsList.Tag='signalsList';
    signalsList.ObjectMethod='hiliteSignalInList';
    signalsList.MethodArgs={'%dialog'};
    signalsList.ArgDataTypes={'handle'};
    signalsList.Source=source;


    renameEdit.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_RenameInputs');
    renameEdit.Type='edit';
    renameEdit.RowSpan=[2,2];
    renameEdit.ColSpan=[1,1];
    renameEdit.Enabled=0;
    renameEdit.Tag='renameEdit';
    renameEdit.ObjectMethod='rename';
    renameEdit.MethodArgs={'%dialog'};
    renameEdit.ArgDataTypes={'handle'};
    renameEdit.Source=source;

    if~isempty(hOpenDialog)
        signalsList.Visible=hOpenDialog.isVisible(signalsList.Tag);
        renameEdit.Visible=hOpenDialog.isVisible(renameEdit.Tag);
        renameEdit.Enabled=hOpenDialog.isEnabled(renameEdit.Tag);
        renameEdit.Value=hOpenDialog.getWidgetValue(renameEdit.Tag);
    else
        signalsList.Visible=isValidationEnabled;
        renameEdit.Visible=isValidationEnabled;
    end

    signalListPanel.Name='Signal List Viewer Hierarchy Viewer';
    signalListPanel.Type='panel';
    signalListPanel.Items={signalsList,renameEdit};
    signalListPanel.LayoutGrid=[2,2];
    signalListPanel.RowStretch=[1,0];
    signalListPanel.RowSpan=[1,1];
    signalListPanel.ColSpan=[1,1];
    signalListPanel.Source=source;
    signalListPanel.Tag='signalListPanel';

    if~isempty(hOpenDialog)
        signalListPanel.Visible=hOpenDialog.isVisible(signalListPanel.Tag);
    else
        signalListPanel.Visible=isValidationEnabled;
    end
end

function[buttonGroup]=createButtonGroup(source,hOpenDialog,isValidationEnabled)



    findButton=source.createFindButton([1,1],[1,1]);
    refreshButton=source.createRefreshButton([2,2],[1,1]);
    upButton=source.createUpButton([3,3],[1,1]);
    downButton=source.createDownButton([4,4],[1,1]);
    addButton=source.createAddButton([5,5],[1,1]);
    removeButton=source.createRemoveButton([6,6],[1,1]);

    findButton.Alignment=3;
    refreshButton.Alignment=3;
    upButton.Alignment=3;
    downButton.Alignment=3;
    addButton.Alignment=3;
    removeButton.Alignment=3;

    if~isempty(hOpenDialog)
        findButton.Visible=hOpenDialog.isVisible(findButton.Tag);
        findButton.Enabled=hOpenDialog.isEnabled(findButton.Tag);

        refreshButton.Visible=hOpenDialog.isVisible(refreshButton.Tag);

        upButton.Visible=hOpenDialog.isVisible(upButton.Tag);
        upButton.Enabled=hOpenDialog.isEnabled(upButton.Tag);

        downButton.Visible=hOpenDialog.isVisible(downButton.Tag);
        downButton.Enabled=hOpenDialog.isEnabled(downButton.Tag);

        addButton.Visible=hOpenDialog.isVisible(addButton.Tag);

        removeButton.Visible=hOpenDialog.isVisible(removeButton.Tag);
        removeButton.Enabled=hOpenDialog.isEnabled(removeButton.Tag);
    else
        findButton.Visible=~isValidationEnabled;
        refreshButton.Visible=~isValidationEnabled;
        upButton.Visible=1;
        downButton.Visible=1;
        addButton.Visible=1;
        removeButton.Visible=1;
    end


    buttonGroup.Name='buttonGroup';
    buttonGroup.Type='panel';
    buttonGroup.RowSpan=[1,1];
    buttonGroup.ColSpan=[2,2];
    buttonGroup.Tag='buttonGroup';
    buttonGroup.Items={findButton,refreshButton,upButton,downButton,addButton,removeButton};
    buttonGroup.LayoutGrid=[7,1];
    buttonGroup.RowStretch=[0,0,0,0,0,0,1];

end

function[outputCheck]=createOutputCheckBox(source)


    outputCheck.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_NVOut');
    outputCheck.Type='checkbox';
    outputCheck.RowSpan=[4,4];
    outputCheck.ColSpan=[1,2];
    outputCheck.ObjectProperty='NonVirtualBus';
    outputCheck.Tag=outputCheck.ObjectProperty;
    outputCheck.MatlabMethod='slDialogUtil';
    outputCheck.MatlabArgs={source,'sync','%dialog','checkbox','%tag'};
end

function[OverrideFromInputsCheckBox]=createOverrideFromInputsCheckBox(source)





    OverrideFromInputsCheckBox.Name=DAStudio.message('Simulink:blkprm_prompts:InheritFromInputs');
    OverrideFromInputsCheckBox.Type='checkbox';
    OverrideFromInputsCheckBox.RowSpan=[2,2];
    OverrideFromInputsCheckBox.ColSpan=[1,2];
    OverrideFromInputsCheckBox.ObjectProperty='InheritFromInputs';
    OverrideFromInputsCheckBox.Tag=OverrideFromInputsCheckBox.ObjectProperty;






    OverrideFromInputsCheckBox.MatlabMethod='inheritNames';
    OverrideFromInputsCheckBox.MatlabArgs={source,'%dialog','%tag'};

end

function[matchCheck]=createSignalMatchCheckBox(source)



    matchCheck.Type='checkbox';
    matchCheck.Name=DAStudio.message('Simulink:dialog:DDGSource_Bus_RequireMatch_New');
    matchCheck.RowSpan=[3,3];
    matchCheck.ColSpan=[1,1];
    matchCheck.ObjectProperty='MatchInputsString';
    matchCheck.Tag=matchCheck.ObjectProperty;






    matchCheck.MatlabMethod='inheritNames';
    matchCheck.MatlabArgs={source,'%dialog','%tag'};

end
