function dlgstruct=getFirstWarningDialogSchema(hView,name)




    Data=hView.mController.getData();

    prompt.Type='text';
    prompt.Name=DAStudio.message('ERRORHANDLER:tgtpref:TargetCopyQuestion');
    prompt.Alignment=5;
    prompt.Tag='message';
    prompt.ColSpan=[2,2];
    prompt.RowSpan=[1,1];

    image.Type='image';
    image.Tag='image';
    image.Alignment=5;
    image.RowSpan=[1,1];
    image.ColSpan=[1,1];
    image.FilePath=fullfile(targetpref.getTargetPrefResourceDir(),'question.png');

    IDEListLabel.Name=hView.mLabels.IDE.IDEName;
    IDEListLabel.Type='text';
    IDEListLabel.RowSpan=[1,1];
    IDEListLabel.ColSpan=[1,1];

    IDEList.Type='combobox';
    IDEList.Entries=Data.getAdaptorNameList();
    IDEList.Value=Data.getCurAdaptorName();
    IDEList.Tag='TargetPrefIDE_IDEList';
    IDEList.ToolTip=hView.mToolTips.IDE.IDEName;
    IDEList.RowSpan=[1,1];
    IDEList.ColSpan=[2,2];


    IDEList.Mode=true;
    IDEList.DialogRefresh=true;
    IDEList.Enabled=~hView.mController.isTargetPrefDlgDisbled();
    IDEList=hView.addControllerCallBack(IDEList,'setIDEFirst','%value');

    BoardNameLabel.Name=hView.mLabels.Board.BoardName;
    BoardNameLabel.Type='text';
    BoardNameLabel.RowSpan=[2,2];
    BoardNameLabel.ColSpan=[1,1];

    BoardName.Type='combobox';
    BoardName.Entries=Data.getBoardTypeList();
    BoardName.Value=Data.getBoardTypeDisplayName();
    BoardName.Tag='TargetPrefBoard_BoardName';
    BoardName.RowSpan=[2,2];
    BoardName.ColSpan=[2,2];
    if(1==length(BoardName.Entries))
        BoardName.Enabled=false;
    else
        BoardName.Enabled=true;
    end
    if(hView.mController.isFactoryBoard())
        BoardName.ToolTip=sprintf(hView.mToolTips.Board.BoardNameFactory,BoardName.Value);
    else
        BoardName.ToolTip=hView.mToolTips.Board.BoardName;
    end
    BoardName.DialogRefresh=true;
    BoardName=hView.addControllerCallBack(BoardName,'setBoardTypeFirst','%value');

    ProcessorNameLabel.Name=hView.mLabels.Board.ProcessorName;
    ProcessorNameLabel.Type='text';
    ProcessorNameLabel.RowSpan=[3,3];
    ProcessorNameLabel.ColSpan=[1,1];

    ProcessorName.Type='combobox';
    ProcessorName.Entries=Data.getChipNameList();
    ProcessorName.Value=Data.getCurChipName();
    ProcessorName.Tag='TargetPrefBoard_ProcessorName';
    ProcessorName.ToolTip=hView.mToolTips.Board.ProcessorName;
    ProcessorName.DialogRefresh=true;
    ProcessorName.RowSpan=[3,3];
    ProcessorName.ColSpan=[2,2];
    if(1==length(ProcessorName.Entries))
        ProcessorName.Enabled=false;
    else
        ProcessorName.Enabled=true;
    end
    ProcessorName=hView.addControllerCallBack(ProcessorName,'setProcessorNameFirst','%value');

    choiceGroup.Type='panel';
    choiceGroup.LayoutGrid=[3,2];
    choiceGroup.ColStretch=[0,1];
    choiceGroup.Items={IDEListLabel,IDEList,BoardNameLabel,BoardName,ProcessorNameLabel,ProcessorName};
    choiceGroup.RowSpan=[2,2];
    choiceGroup.ColSpan=[1,2];

    prompt2.Type='text';
    prompt2.Name=DAStudio.message('ERRORHANDLER:tgtpref:TargetCopyQuestion2');
    prompt2.Alignment=5;
    prompt2.Tag='message2';
    prompt2.RowSpan=[4,4];
    prompt2.ColSpan=[1,2];

    choices=hView.mController.getQuestionChoices();
    items=cell(1,numel(choices));
    for i=1:numel(items)
        button.Type='pushbutton';
        button.Name=choices{i};
        tag=['QuestDlg_',choices{i}];
        button.Tag=tag;
        button=hView.addControllerCallBack(button,'questionResponse',sprintf('%d',i));
        button.RowSpan=[1,1];
        button.ColSpan=[i,i];
        items{i}=button;
    end

    button.Type='pushbutton';
    button.Name=hView.mLabels.IDE.Help;
    tag='QuestDlg_Help';
    button.Tag=tag;
    button=hView.addControllerCallBack(button,'showFirstWarningHelp');
    button.RowSpan=[1,1];
    button.ColSpan=[3,3];
    items{3}=button;

    buttonGroup.Type='panel';
    buttonGroup.LayoutGrid=[1,1];
    buttonGroup.Items=items;
    buttonGroup.RowSpan=[5,5];
    buttonGroup.ColSpan=[1,2];
    buttonGroup.Alignment=6;

    dlgstruct.DialogTitle=hView.mController.getQuestionTitle();
    dlgstruct.DialogTag=name;
    dlgstruct.LayoutGrid=[5,2];
    dlgstruct.ColStretch=[0,1];
    dlgstruct.RowStretch=[0,0,1,0,0];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.Sticky=true;
    dlgstruct.Items={image,prompt,choiceGroup,prompt2,buttonGroup};
    dlgstruct.CloseMethod='closeDialog';
    dlgstruct.CloseMethodArgs={'%dialog',dlgstruct.DialogTag};
    dlgstruct.CloseMethodArgsDT={'handle','mxArray'};
