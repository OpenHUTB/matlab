



function dlg=launch(varargin)
    dlg=autosar.ui.wizard.WizardDialog(varargin{:});
    daStudioDlg=DAStudio.Dialog(dlg);
    dlg.setDialog(daStudioDlg);
end
