function dlgstruct=getDialogSchema(this,~)



    Hierarchy.Name='Select the HDL component';
    Hierarchy.Tag='edaHdlHierarchyTree';
    Hierarchy.Type='tree';
    Hierarchy.RowSpan=[1,1];
    if(this.ShowPorts)
        Hierarchy.ColSpan=[1,4];
    else
        Hierarchy.ColSpan=[1,8];
    end
    Hierarchy.TreeItems=this.TreeItems;
    Hierarchy.ObjectProperty='SelectedTreeItem';
    Hierarchy.ObjectMethod='onClickNode';
    Hierarchy.MethodArgs={'%dialog'};
    Hierarchy.ArgDataTypes={'handle'};
    Hierarchy.ListenToProperties={'TreeItems'};
    Hierarchy.Mode=true;
    Hierarchy.Visible=true;
    Hierarchy.ExpandTree=false;


    PortList.Name='';
    PortList.Type='table';
    PortList.Tag='edaPortList';
    PortList.RowSpan=[1,1];
    PortList.ColSpan=[5,8];
    PortList.ColHeader={'Port Name','Port Type'};
    PortList.RowHeader={};
    PortList.Editable=false;
    PortList.Data=this.TableItems;
    PortList.Size=size(this.TableItems);
    PortList.HeaderVisibility=[0,1];
    PortList.SelectionBehavior='row';
    PortList.Visible=this.ShowPorts;


    TablePanel.Type='panel';
    TablePanel.Tag='edaTablePanel';
    TablePanel.Name='';
    TablePanel.LayoutGrid=[1,2];
    TablePanel.RowSpan=[1,1];
    TablePanel.ColSpan=[1,8];
    TablePanel.Items={Hierarchy,PortList};

    FillBtn.Name='OK';
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


    ButtonPanel.Type='panel';
    ButtonPanel.Tag='edaBtnPanel';
    ButtonPanel.Name='Buttons';
    ButtonPanel.LayoutGrid=[1,3];
    ButtonPanel.RowSpan=[2,2];
    ButtonPanel.ColSpan=[5,8];
    ButtonPanel.Items={FillBtn,CancelBtn,HelpBtn};


    dlgstruct.DialogTitle='HDL Design Browser';

    dlgstruct.LayoutGrid=[2,8];
    dlgstruct.ColStretch=[1,1,1,1,1,1,1,1];
    dlgstruct.Items={TablePanel,ButtonPanel};



    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.Sticky=true;


    dlgstruct.DialogTag=class(this);

end


