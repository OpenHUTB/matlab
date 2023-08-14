function dlgstruct=getDialogSchema(h,~)



    editpath.Name='Path';
    editpath.Tag='edaEditPath';
    editpath.HideName=true;
    editpath.Type='edit';
    editpath.RowSpan=[1,1];
    if(h.AllowBrowseButton)
        editpath.ColSpan=[1,4];
    else
        editpath.ColSpan=[1,5];
    end
    editpath.ObjectProperty='Path';
    editpath.ObjectMethod='onFill';
    editpath.MethodArgs={'%dialog'};
    editpath.ArgDataTypes={'handle'};
    editpath.Mode=true;

    Hierarchy.Name='Hierarchy';
    Hierarchy.Tag='edaHierarchy';
    Hierarchy.Type='tree';
    Hierarchy.RowSpan=[2,2];
    Hierarchy.ColSpan=[1,5];
    Hierarchy.TreeItems=h.TreeItems;
    Hierarchy.ObjectProperty='SelectedTreeItem';
    Hierarchy.ObjectMethod='onClickNode';
    Hierarchy.MethodArgs={'%dialog'};
    Hierarchy.ArgDataTypes={'handle'};
    Hierarchy.ListenToProperties={'TreeItems'};
    Hierarchy.Mode=true;
    Hierarchy.Visible=h.EnableBrowser;


    browseButton.Name='Browse';
    browseButton.Type='pushbutton';
    browseButton.Tag='edaBrowseBtn';
    browseButton.RowSpan=[1,1];
    browseButton.ColSpan=[5,5];
    browseButton.ObjectMethod='onBrowse';
    browseButton.MethodArgs={'%dialog'};
    browseButton.ArgDataTypes={'handle'};
    browseButton.Visible=h.AllowBrowseButton;

    FillBtn.Name='Fill';
    FillBtn.Tag='edaFillBtn';
    FillBtn.Type='pushbutton';
    FillBtn.ObjectMethod='onFill';
    FillBtn.MethodArgs={'%dialog'};
    FillBtn.ArgDataTypes={'handle'};
    FillBtn.RowSpan=[1,1];
    FillBtn.ColSpan=[1,1];

    CancelBtn.Name='Cancel';
    CancelBtn.Tag='edaCancelBtn';
    CancelBtn.Type='pushbutton';
    CancelBtn.ObjectMethod='onCancel';
    CancelBtn.MethodArgs={'%dialog'};
    CancelBtn.ArgDataTypes={'handle'};
    CancelBtn.RowSpan=[1,1];
    CancelBtn.ColSpan=[2,2];

    HelpBtn.Name='Help';
    HelpBtn.Tag='edaHelpBtn';
    HelpBtn.Type='pushbutton';
    HelpBtn.ObjectMethod='onHelp';
    HelpBtn.RowSpan=[1,1];
    HelpBtn.ColSpan=[3,3];


    oc.Type='group';
    oc.Name='Enter full path to component or module instance';
    oc.LayoutGrid=[2,5];
    oc.RowSpan=[1,2];
    oc.ColSpan=[1,5];
    oc.Items={editpath,Hierarchy,browseButton};


    ButtonPanel.Type='panel';
    ButtonPanel.Tag='edaBtnPanel';
    ButtonPanel.Name='Buttons';
    ButtonPanel.LayoutGrid=[1,3];
    ButtonPanel.RowSpan=[3,3];
    ButtonPanel.ColSpan=[3,5];
    ButtonPanel.Items={FillBtn,CancelBtn,HelpBtn};


    dlgstruct.DialogTitle='Auto Fill';
    dlgstruct.LayoutGrid=[3,5];
    dlgstruct.Items={oc,ButtonPanel};
    dlgstruct.DialogTag=class(h);


    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.Sticky=true;


