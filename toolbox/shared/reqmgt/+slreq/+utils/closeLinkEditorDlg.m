function found=closeLinkEditorDlg()
    tr=DAStudio.ToolRoot;
    dialogs=tr.getOpenDialogs.find('dialogTag','rmiDlg');
    found=numel(dialogs);
    for dlg=dialogs(:)'
        try
            delete(dlg);
        catch ME %#ok<NASGU>
        end
    end
end
