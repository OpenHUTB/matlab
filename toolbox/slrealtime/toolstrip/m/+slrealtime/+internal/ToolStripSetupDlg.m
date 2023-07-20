classdef ToolStripSetupDlg<coder.internal.toolstrip.SetupConfigSetDialog




    methods
        function obj=ToolStripSetupDlg(model,cs)
            obj=obj@coder.internal.toolstrip.SetupConfigSetDialog(model,cs);
        end

        function msg=getMessageText(~)
            msg=getString(message('slrealtime:toolstrip:SetupDialogMessage'));
        end


        function dlgstruct=createDialogLayout(~,icon,msg,buttonPanel)
            dialogTitle=getString(message('slrealtime:toolstrip:SetupDialogTitle'));

            dlgstruct.DialogTitle=dialogTitle;
            dlgstruct.DialogTag=coder.internal.toolstrip.SetupConfigSetDialog.getDialogTag();
            dlgstruct.Items={icon,msg,buttonPanel};
            dlgstruct.LayoutGrid=[2,2];
            dlgstruct.ColStretch=[0,1];
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.Sticky=true;
        end
    end
end

