function dlgstruct=getQuestionDialogSchema(hView,name)







    prompt.Type='text';
    prompt.Name=hView.mController.getQuestionPrompt();
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

    buttonGroup.Type='panel';
    buttonGroup.LayoutGrid=[1,1];
    buttonGroup.Items=items;
    buttonGroup.RowSpan=[2,2];
    buttonGroup.ColSpan=[1,2];
    buttonGroup.Alignment=6;

    dlgstruct.DialogTitle=hView.mController.getQuestionTitle();
    dlgstruct.DialogTag=name;
    dlgstruct.LayoutGrid=[2,2];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.Sticky=true;
    dlgstruct.Items={image,prompt,buttonGroup};
    dlgstruct.CloseMethod='closeDialog';
    dlgstruct.CloseMethodArgs={'%dialog',dlgstruct.DialogTag};
    dlgstruct.CloseMethodArgsDT={'handle','mxArray'};
