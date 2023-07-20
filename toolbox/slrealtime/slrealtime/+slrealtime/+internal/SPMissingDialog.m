




classdef SPMissingDialog<handle
    properties
        closeListener;
    end

    methods
        function launchInstaller(obj)
            obj.dismissDialog;
            matlab.addons.supportpackage.internal.explorer.showSupportPackages('SLRT_QNX','tripwire');
        end

        function dismissDialog(obj)
            obj.delete;
        end

        function dlgStruct=getDialogSchema(obj)%#ok<MANU>
            msgLbl.Type='text';
            msgLbl.Tag='SPMissingDialog_msgLabel';
            msgLbl.Name=DAStudio.message('slrealtime:supportpackage:supportPackageRequiredMsg');

            installButton.Type='pushbutton';
            installButton.Name=DAStudio.message('slrealtime:supportpackage:installSPButtonStr');
            installButton.Tag='SPMissingDialog_installButton';
            installButton.ObjectMethod='launchInstaller';
            installButton.RowSpan=[1,1];
            installButton.ColSpan=[1,1];

            dismissButton.Type='pushbutton';
            dismissButton.Name=DAStudio.message('slrealtime:supportpackage:cancelButtonStr');
            dismissButton.Tag='SPMissingDialog_dismissButton';
            dismissButton.ObjectMethod='dismissDialog';
            dismissButton.RowSpan=[1,1];
            dismissButton.ColSpan=[2,2];

            buttonPanel.Type='panel';
            buttonPanel.Tag='SPMissingDialog_buttonPanel';
            buttonPanel.Items={installButton,dismissButton};
            buttonPanel.LayoutGrid=[1,3];

            dlgStruct.Items={msgLbl};
            dlgStruct.DialogTitle=DAStudio.message('slrealtime:supportpackage:supportPackageRequired');
            dlgStruct.DialogTag='SPMissingDialog';
            dlgStruct.StandaloneButtonSet=buttonPanel;
            dlgStruct.ShowGrid=false;
        end
    end
end


