function selectButtonCB(this,dlg)






    set_param(this.StateAccessorBlock,'StateOwnerBlock',this.TreeSelectedItem);
    this.StateAccessorBlockDlg.refresh;
    this.closeDlg(dlg);

