
function dlgstruct=getDialogSchema(this)

    panel=struct('Type','panel','LayoutGrid',[3,1],'RowStretch',[0,0,1]);

    panel.Items={};



    [group,grid]=this.getMultipleSpecs();
    panel.Items{end+1}=group;

    dlgstruct.DialogTag='ReqIFPanelTestDlg';
    dlgstruct.DialogTitle='';

    dlgstruct.Items={panel};

    dlgstruct.CloseMethod='ReqIFPanelTestDlg_Cancel_callback';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};

    dlgstruct.Sticky=true;
end