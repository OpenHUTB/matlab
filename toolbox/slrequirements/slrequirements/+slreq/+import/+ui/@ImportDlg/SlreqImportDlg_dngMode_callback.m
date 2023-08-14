function SlreqImportDlg_dngMode_callback(this,dlg)



    this.connectionMode=dlg.getWidgetValue('DngOptions_mode');

    this.refreshDlg(dlg);
end
