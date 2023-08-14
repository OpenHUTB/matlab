function showFolderClonesDialogCallback(cbinfo)

    cloneDetectionUIObj=get_param(cbinfo.model.handle,'CloneDetectionUIObj');

    dlg=CloneDetectionUI.internal.util.findExistingDlg(cbinfo.model.handle,'FindAcrossFolders');

    if isempty(dlg)
        dlg=CloneDetectionUI.internal.DDGViews.AcrossFolders(cloneDetectionUIObj);
    end

    CloneDetectionUI.internal.util.show(dlg);
end

