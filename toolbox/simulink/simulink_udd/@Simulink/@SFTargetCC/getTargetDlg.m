function dlgstruct=getTargetDlg(h,name)







    txtName.Name='Target Name:';
    txtName.Type='edit';
    txtName.RowSpan=[1,1];
    txtName.ColSpan=[1,10];
    txtName.ObjectProperty='Name';
    txtName.Tag=strcat('sfTargetdlg_',txtName.Name);





    lblParent.Name='Parent:';
    lblParent.Type='text';
    lblParent.RowSpan=[2,2];
    lblParent.ColSpan=[1,2];
    lblParent.Tag=strcat('sfTargetdlg_',lblParent.Name);








    hypParent.Name='No parent';
    hypParent.Enabled=0;

    hypParent.Type='hyperlink';
    hypParent.RowSpan=[2,2];
    hypParent.ColSpan=[2,10];





    lblTL.Name='Target Language:';
    lblTL.Type='text';
    lblTL.RowSpan=[3,3];
    lblTL.ColSpan=[1,2];
    lblTL.Tag=strcat('sfTargetdlg_',lblTL.Name);

    lblTLv.Name='ANSI-C';
    lblTLv.Type='text';
    lblTLv.RowSpan=[3,3];
    lblTLv.ColSpan=[3,4];
    lblTLv.Tag=strcat('sfTargetdlg_',lblTLv.Name);





    cmbTarget.Type='combobox';
    cmbTarget.RowSpan=[4,4];
    cmbTarget.ColSpan=[1,10];
    cmbTarget.DialogRefresh=1;
    cmbTarget.Tag='cmbTarget';
    cmbTarget.Entries={'Stateflow Target (incremental)',...
    'Rebuild All (including libraries)',...
    'Make without generating code',...
    'Generate code only (incremental)',...
    'Generate code only (non - incremental)'};
    cmbTarget.ObjectProperty='SelectedCmd';




    btnTarget.Name='Target Options';
    btnTarget.Type='pushbutton';
    btnTarget.RowSpan=[5,5];
    btnTarget.ColSpan=[1,2];
    btnTarget.ObjectMethod='createChildDlg';
    btnTarget.MethodArgs={btnTarget.Name};
    btnTarget.ArgDataTypes={'string'};

    btnCoder.Name='Coder Options';
    btnCoder.Type='pushbutton';
    btnCoder.RowSpan=[5,5];
    btnCoder.ColSpan=[3,4];
    btnCoder.ObjectMethod='createChildDlg';
    btnCoder.MethodArgs={btnCoder.Name};
    btnCoder.ArgDataTypes={'string'};










    buildCommands=[];
    btnBuild.Name='Disabled';
    btnBuild.Enabled=0;


    btnBuild.Type='pushbutton';
    btnBuild.RowSpan=[5,5];
    btnBuild.Tag='btnBuildTag';
    btnBuild.ColSpan=[8,10];




    chkLibSet.Name='Use settings for all libraries';
    chkLibSet.Type='checkbox';
    chkLibSet.RowSpan=[6,6];
    chkLibSet.ColSpan=[1,10];
    chkLibSet.ObjectProperty='ApplyToAllLibs';
    chkLibSet.Tag=strcat('sfTargetdlg_',chkLibSet.Name);





    desc.Name=DAStudio.message('RTW:configSet:configSetDescription');
    desc.Type='editarea';
    desc.RowSpan=[7,7];
    desc.ColSpan=[1,10];
    desc.ObjectProperty='Description';
    desc.Tag=strcat('sfTargetdlg_',desc.Name);





    doclinkName.Name='Document Link:';
    doclinkName.RowSpan=[8,8];
    doclinkName.ColSpan=[1,4];
    doclinkName.Type='hyperlink';
    doclinkName.Tag='doclinkNameTag';
    doclinkName.MatlabMethod='sf';
    doclinkName.MatlabArgs={'Private','dlg_goto_document',h.Id};


    doclinkEdit.Name='';
    doclinkEdit.RowSpan=[8,8];
    doclinkEdit.ColSpan=[4,10];
    doclinkEdit.Type='edit';
    doclinkEdit.ObjectProperty='Document';
    doclinkEdit.Tag='sfTargetdlg_doclinkEdit';


    pnlMain.Type='panel';
    pnlMain.LayoutGrid=[8,10];
    pnlMain.Items={txtName,...
    lblParent,hypParent,...
    lblTL,lblTLv,...
    cmbTarget,...
    btnTarget,btnCoder,btnBuild,...
    chkLibSet,...
    desc,...
    doclinkName,doclinkEdit};
    pnlMain.Tag='sfTargetdlg_pnlMain';




    if strcmp(name,'tab')
        dlgstruct.Name=get(h,'Name');
    else
        dlgstruct.DialogTitle='Stateflow Target Builder';
    end
    dlgstruct.Items={pnlMain};


