function dlg=getDialogSchema(h,name)





    persistent dlg_struct;
    persistent dlg_struct_mdlref;
    persistent dlg_struct_empty;
    mlock;


    if isempty(dlg_struct_mdlref)

        helpTxt.Name=...
        DAStudio.message('Simulink:Logging:SigLogDlgMdlRefHelpTxtContent');
        helpTxt.RowSpan=[1,1];
        helpTxt.ColSpan=[1,1];
        helpTxt.Type='text';
        helpTxt.Tag='SigLogDlgHelpText';


        dlg_struct_mdlref.DialogTitle=...
        DAStudio.message('Simulink:Logging:SigLogDlgMdlRefHelpTxtTitle');
        dlg_struct_mdlref.Items={helpTxt};
        dlg_struct_mdlref.LayoutGrid=[2,1];
        dlg_struct_mdlref.RowStretch=[0,1];
        dlg_struct_mdlref.Source=h;
        dlg_struct_mdlref.IsScrollable=false;
        dlg_struct_mdlref.EmbeddedButtonSet={''};
    end


    if isempty(dlg_struct)

        helpTxt.Name=...
        DAStudio.message('Simulink:Logging:SigLogDlgNonMdlRefHelpTxtContent');
        helpTxt.RowSpan=[1,1];
        helpTxt.ColSpan=[1,1];
        helpTxt.Type='text';
        helpTxt.Tag='SigLogDlgHelpText';


        dlg_struct.DialogTitle=...
        DAStudio.message('Simulink:Logging:SigLogDlgNonMdlRefHelpTxtTitle');
        dlg_struct.Items={helpTxt};
        dlg_struct.LayoutGrid=[2,1];
        dlg_struct.RowStretch=[0,1];
        dlg_struct.Source=h;
        dlg_struct.IsScrollable=false;
        dlg_struct.EmbeddedButtonSet={''};
    end


    if isempty(dlg_struct_empty)
        sig=SigLogSelector.EmptySigObj;
        dlg_struct_empty=sig.getDialogSchema(name);
    end


    me=SigLogSelector.getExplorer;
    if isa(h,'SigLogSelector.MdlRefNode')
        if~isempty(h.hBdNode)&&...
            h.hBdNode.signalsPopulated&&isempty(h.hBdNode.signalChildren)
            dlg=dlg_struct_empty;
        else
            dlg=dlg_struct_mdlref;
        end
    elseif isa(h,'SigLogSelector.SubSysNode')&&...
        h.signalsPopulated&&isempty(h.signalChildren)
        dlg=dlg_struct_empty;
    elseif~isempty(me)&&me.displayMdlRefHelp
        dlg=dlg_struct_mdlref;
    else
        dlg=dlg_struct;
    end

end
