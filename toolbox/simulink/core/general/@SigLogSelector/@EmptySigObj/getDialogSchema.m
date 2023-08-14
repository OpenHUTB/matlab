function dlg=getDialogSchema(h,name)%#ok





    persistent dlg_struct;
    mlock;
    if~isempty(dlg_struct)
        dlg=dlg_struct;
        return;
    end


    helpTxt.Name=...
    DAStudio.message('Simulink:Logging:SigLogDlgEmptyHelpTxtContent');
    helpTxt.RowSpan=[1,1];
    helpTxt.ColSpan=[1,1];
    helpTxt.Type='text';
    helpTxt.Tag='SigLogDlgHelpText';


    dlg.DialogTitle=...
    DAStudio.message('Simulink:Logging:SigLogDlgEmptyHelpTxtTitle');
    dlg.Items={helpTxt};
    dlg.LayoutGrid=[2,1];
    dlg.RowStretch=[0,1];
    dlg.Source=h;
    dlg.IsScrollable=false;
    dlg.EmbeddedButtonSet={''};
    dlg_struct=dlg;

end
