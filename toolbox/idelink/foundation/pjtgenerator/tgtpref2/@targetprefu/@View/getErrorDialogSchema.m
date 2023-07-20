function dlgstruct=getErrorDialogSchema(hView,name)







    message.Type='text';
    message.Name=hView.mController.getWarningErrorMessage();
    message.Alignment=5;
    message.Tag='message';
    message.ColSpan=[2,2];
    message.RowSpan=[1,1];

    image.Type='image';
    image.Tag='image';
    image.Alignment=5;
    image.RowSpan=[1,1];
    image.ColSpan=[1,1];
    if(strcmp(name,'Warning'))
        image.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','warning.bmp');
    else
        image.FilePath=fullfile(targetpref.getTargetPrefResourceDir(),'error.png');
    end

    button.Type='pushbutton';
    button.Name='OK';
    button.ObjectMethod='dismissDialog';
    button.MethodArgs={'%dialog',name};
    button.ArgDataTypes={'handle','mxArray'};

    buttonGroup.Type='panel';
    buttonGroup.LayoutGrid=[1,1];
    buttonGroup.Items={button};
    buttonGroup.RowSpan=[2,2];
    buttonGroup.ColSpan=[1,2];
    buttonGroup.Alignment=6;
    if(strcmp(name,'Warning'))
        dlgstruct.DialogTitle=hView.mController.getWarningTitle();
    else
        dlgstruct.DialogTitle=hView.mController.getErrorTitle();
    end
    dlgstruct.DialogTag=name;
    dlgstruct.LayoutGrid=[2,2];
    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.Sticky=true;
    dlgstruct.Items={image,message,buttonGroup};
    dlgstruct.CloseMethod='closeDialog';
    dlgstruct.CloseMethodArgs={'%dialog',dlgstruct.DialogTag};
    dlgstruct.CloseMethodArgsDT={'handle','mxArray'};
