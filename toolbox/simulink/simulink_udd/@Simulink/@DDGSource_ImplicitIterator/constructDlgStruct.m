function dlgStruct=constructDlgStruct(this,items,numRows)





    block=this.getBlock;
    rowspan=0;


    descText.Name=block.BlockDescription;
    descText.Type='text';
    descText.WordWrap=true;
    descText.RowSpan=[1,1];
    descText.ColSpan=[1,3];

    descLink.Name=DAStudio.message('Simulink:dialog:ForEachTutorialLink');
    descLink.Type='hyperlink';
    descLink.Tag='WorkingWithForEachSubsystem';
    descLink.MatlabMethod='helpview';
    descLink.MatlabArgs={fullfile(docroot,'simulink','helptargets.map'),'WorkingWithForEachSubsystem'};
    descLink.RowSpan=[2,2];
    descLink.ColSpan=[2,2];

    descLinkTxt.Name=DAStudio.message('Simulink:dialog:ForEachTutorialPromp');
    descLinkTxt.Type='text';
    descLinkTxt.RowSpan=[2,2];
    descLinkTxt.ColSpan=[1,1];


    rowspan=rowspan+1;
    descGroup.Name=block.BlockType;
    descGroup.Type='group';
    descGroup.Items={descText,descLinkTxt,descLink};
    descGroup.RowSpan=[rowspan,rowspan];
    descGroup.ColSpan=[1,1];
    descGroup.LayoutGrid=[2,3];
    descGroup.RowStretch=[0,0];
    descGroup.ColStretch=[0,0,1];

    paramFeatureOn=(slfeature('ForEachSubsystemParameterization')==1);
    if~paramFeatureOn

        rowspan=rowspan+1;
        inputGroup.Name=DAStudio.message('Simulink:dialog:ForEachInputGroupPromp');
        inputGroup.Type='group';
        inputGroup.Items=items([3,1]);
        inputGroup.LayoutGrid=[numRows(1)+1,3];
        inputGroup.RowStretch=[zeros(1,numRows(1)),1];
        inputGroup.ColStretch=[0,0,1];
        inputGroup.RowSpan=[rowspan,rowspan];
        inputGroup.ColSpan=[1,1];
        inputGroup.Source=block;


        rowspan=rowspan+1;
        outputGroup.Name=DAStudio.message('Simulink:dialog:ForEachOutputGroupPromp');
        outputGroup.Type='group';
        outputGroup.Items=items([4,2]);
        outputGroup.LayoutGrid=[numRows(2)+1,3];
        outputGroup.RowStretch=[zeros(1,numRows(2)),1];
        outputGroup.ColStretch=ones(1,1);
        outputGroup.RowSpan=[rowspan,rowspan];
        outputGroup.ColSpan=[1,1];
        outputGroup.Source=block;

    else

        inputTabItem.Name=DAStudio.message('Simulink:dialog:ForEachInputGroupPromp');
        inputTabItem.Items=items([3,1]);
        inputTabItem.Tag='tabInput';
        inputTabItem.WidgetId='tabInput_widgetid';
        inputTabItem.Visible=true;


        outputTabItem.Name=DAStudio.message('Simulink:dialog:ForEachOutputGroupPromp');
        outputTabItem.Items=items([4,2]);
        outputTabItem.Tag='tabOutput';
        outputTabItem.WidgetId='tabOutput_widgetid';
        outputTabItem.Visible=true;


        paramTabItem.Name=DAStudio.message('Simulink:dialog:ForEachMaskPrmGroupPromp');
        paramTabItem.Items=items([5,6]);
        paramTabItem.Tag='tabParam';
        paramTabItem.WidgetId='tabParam_widgetid';
        paramTabItem.Visible=true;

        rowspan=rowspan+1;
        partitionTab.Name=DAStudio.message('Simulink:dialog:ForEachMaskPrmGroupPromp');
        partitionTab.Type='tab';
        partitionTab.Tabs={inputTabItem,paramTabItem,outputTabItem};
        locNumRows=max(numRows);
        partitionTab.LayoutGrid=[locNumRows+1,3];
        partitionTab.RowStretch=[zeros(1,locNumRows),1];
        partitionTab.ColStretch=[0,0,1];
        partitionTab.RowSpan=[rowspan,rowspan];
        partitionTab.ColSpan=[1,1];
        partitionTab.Source=block;
    end

    exposePartitionIndexFeatureOn=(slfeature('ForEachSubsystemExposingPartitionIndex')>0);
    if exposePartitionIndexFeatureOn

        exposePartitionIndexCheckbox=this.initWidget('ShowIterationIndex',false);
        exposePartitionIndexCheckbox.Tag='_Show_Partition_Index_';
        exposePartitionIndexCheckbox.RowSpan=[1,1];
        exposePartitionIndexCheckbox.ColSpan=[1,1];


        partitionIndexDataTypeCombobox=this.initWidget('IterationIndexDataType',false);
        partitionIndexDataTypeCombobox.Tag='_Partition_Index_Data_Type_';
        partitionIndexDataTypeCombobox.RowSpan=[2,2];
        partitionIndexDataTypeCombobox.ColSpan=[1,1];
        partitionIndexDataTypeCombobox.Enabled=strcmp(this.DialogData.ShowIterationIndex,'on');

        rowspan=rowspan+1;
        partitionIndexGroup.Type='panel';
        partitionIndexGroup.Items={exposePartitionIndexCheckbox,partitionIndexDataTypeCombobox};
        partitionIndexGroup.RowSpan=[rowspan,rowspan];
        partitionIndexGroup.ColSpan=[1,1];
        partitionIndexGroup.LayoutGrid=[2,1];
    end

    specNumItersFeatureOn=slfeature('ForEachSubsystemSpecifyNumIters')==1;
    if specNumItersFeatureOn
        rowspan=rowspan+1;
        specNumItersBox=this.initWidget('SpecifiedNumIters',false);
        specNumItersBox.Tag='SpecifiedNumIters_edit';
        specNumItersBox.RowSpan=[rowspan,rowspan];
        specNumItersBox.ColSpan=[1,1];
    end



    dlgStruct.DialogTitle=DAStudio.message('Simulink:dialog:ForEachDlgTitle',strrep(block.Name,sprintf('\n'),' '));
    dlgStruct.DialogTag='foreach_ddg';
    if~paramFeatureOn
        dlgStruct.Items={descGroup,inputGroup,outputGroup};
    else
        dlgStruct.Items={descGroup,partitionTab};
    end

    if exposePartitionIndexFeatureOn
        dlgStruct.Items=[dlgStruct.Items,{partitionIndexGroup}];
    end

    if specNumItersFeatureOn
        dlgStruct.Items=[dlgStruct.Items,{specNumItersBox}];
    end
    dlgStruct.LayoutGrid=[rowspan,1];
    dlgStruct.RowStretch=[0,1,zeros(1,rowspan-2)];
    dlgStruct.ColStretch=[1];
    dlgStruct.ShowGrid=false;
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={block.Handle};

    dlgStruct.PreApplyMethod='PreApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='CloseCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=this.isLibraryBlock(block);
    isLibraryLink=any(strcmp(get_param(block.Handle,'LinkStatus'),{'implicit','resolved'}));
    if isLocked||isLibraryLink
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end
