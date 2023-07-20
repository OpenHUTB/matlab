function dlgStruct=getDialogSchema(h,~)

    nodeNameLabel.Name='Node Name: ';
    nodeNameLabel.Type='text';
    nodeNameLabel.RowSpan=[1,1];
    nodeNameLabel.ColSpan=[1,1];
    nodeNameLabel.Tag='NodeNameLabel';

    nodeName.Name=h.NodeName;
    nodeName.Type='hyperlink';
    nodeName.RowSpan=[1,1];
    nodeName.ColSpan=[2,2];
    nodeName.Tag='NodeName';
    nodeName.ObjectMethod='hiliteNode';
    nodeName.MethodArgs={};
    nodeName.ArgDataTypes={};

    nodeNamePanel.Type='panel';
    nodeNamePanel.Items={nodeNameLabel,nodeName};
    nodeNamePanel.LayoutGrid=[1,2];
    nodeNamePanel.RowStretch=[1];
    nodeNamePanel.ColStretch=[0,1];
    nodeNamePanel.RowSpan=[1,1];
    nodeNamePanel.ColSpan=[1,2];

    nodeTypeLabel.Name='Node Type: ';
    nodeTypeLabel.Type='text';
    nodeTypeLabel.RowSpan=[1,1];
    nodeTypeLabel.ColSpan=[1,1];
    nodeTypeLabel.Tag='NodeTypeLabel';

    nodeType.Name=h.NodeType;
    nodeType.Type='text';
    nodeType.RowSpan=[1,1];
    nodeType.ColSpan=[2,2];
    nodeType.Tag='NodeType';

    nodeTypePanel.Type='panel';
    nodeTypePanel.Items={nodeTypeLabel,nodeType};
    nodeTypePanel.LayoutGrid=[1,2];
    nodeTypePanel.RowStretch=[1];
    nodeTypePanel.ColStretch=[0,1];
    nodeTypePanel.RowSpan=[2,2];
    nodeTypePanel.ColSpan=[1,2];

    pExecutionTimeLabel.Name='Parallel Execution Time: ';
    pExecutionTimeLabel.Type='text';
    pExecutionTimeLabel.RowSpan=[1,1];
    pExecutionTimeLabel.ColSpan=[1,1];
    pExecutionTimeLabel.Tag='ParallelExecutionTimeLabel';

    pExecutionTime.Name=num2str(h.ParallelExecutionTime);
    pExecutionTime.Type='text';
    pExecutionTime.RowSpan=[1,1];
    pExecutionTime.ColSpan=[2,2];
    pExecutionTime.Tag='ParallelExecutionTime';

    pExecutionTimePanel.Type='panel';
    pExecutionTimePanel.Items={pExecutionTimeLabel,pExecutionTime};
    pExecutionTimePanel.LayoutGrid=[1,2];
    pExecutionTimePanel.RowStretch=[1];
    pExecutionTimePanel.ColStretch=[0,1];
    pExecutionTimePanel.RowSpan=[3,3];
    pExecutionTimePanel.ColSpan=[1,2];

    sExecutionTimeLabel.Name='Serial Execution Time: ';
    sExecutionTimeLabel.Type='text';
    sExecutionTimeLabel.RowSpan=[1,1];
    sExecutionTimeLabel.ColSpan=[1,1];
    sExecutionTimeLabel.Tag='SerialExecutionTimeLabel';

    sExecutionTime.Name=num2str(h.SerialExecutionTime);
    sExecutionTime.Type='text';
    sExecutionTime.RowSpan=[1,1];
    sExecutionTime.ColSpan=[2,2];
    sExecutionTime.Tag='SerialExecutionTime';

    sExecutionTimePanel.Type='panel';
    sExecutionTimePanel.Items={sExecutionTimeLabel,sExecutionTime};
    sExecutionTimePanel.LayoutGrid=[1,2];
    sExecutionTimePanel.RowStretch=[1];
    sExecutionTimePanel.ColStretch=[0,1];
    sExecutionTimePanel.RowSpan=[4,4];
    sExecutionTimePanel.ColSpan=[1,2];

    rowNum=5;
    if(~isempty(h.PreviousExecutionMode))
        previousExecutionModeLabel.Name=...
        'Previous Execution Mode: ';
        previousExecutionModeLabel.Type='text';
        previousExecutionModeLabel.RowSpan=[1,1];
        previousExecutionModeLabel.ColSpan=[1,1];
        previousExecutionModeLabel.Tag=...
        'PreviousExecutionModeLabel';

        previousExecutionMode.Name=h.PreviousExecutionMode;
        previousExecutionMode.Type='text';
        previousExecutionMode.RowSpan=[1,1];
        previousExecutionMode.ColSpan=[2,2];
        previousExecutionMode.Tag='PreviousExecutionMode';

        previousExecutionModePanel.Type='panel';
        previousExecutionModePanel.Items={previousExecutionModeLabel,previousExecutionMode};
        previousExecutionModePanel.LayoutGrid=[1,2];
        previousExecutionModePanel.RowStretch=[1];
        previousExecutionModePanel.ColStretch=[0,1];
        previousExecutionModePanel.RowSpan=[rowNum,rowNum];
        previousExecutionModePanel.ColSpan=[1,2];
        rowNum=rowNum+1;
    end
    executionMode.Name='Execution Mode: ';
    executionMode.Type='combobox';
    executionMode.Entries=...
    h.getPropAllowedValues('ExecutionMode')';
    executionMode.RowSpan=[rowNum,rowNum];
    executionMode.ColSpan=[1,2];
    executionMode.Value=h.ExecutionMode;
    executionMode.Tag='ExecutionMode';

    descGroup.Name='Node Properties';
    descGroup.Type='group';
    descGroup.Items=...
    {nodeNamePanel,nodeTypePanel,...
    pExecutionTimePanel,...
    sExecutionTimePanel,executionMode};
    if(~isempty(h.PreviousExecutionMode))
        descGroup.Items=...
        [descGroup.Items,previousExecutionModePanel];
    end

    descGroup.LayoutGrid=[rowNum+1,3];
    if(~isempty(h.PreviousExecutionMode))
        descGroup.RowStretch=[0,0,0,0,0,0,1];
    else
        descGroup.RowStretch=[0,0,0,0,0,1];
    end
    descGroup.ColStretch=[0,0,1];



    title='Parallel Execution Node';
    dlgStruct.DialogTitle=title;

    dlgStruct.Items={descGroup};
    dlgStruct.Source=h;
    dlgStruct.PostApplyCallback='setDialogProperties';
    dlgStruct.PostApplyArgs={'%source','%dialog'};
    dlgStruct.PostApplyArgsDT={'handle','handle'};


end

