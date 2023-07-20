function selectDetectionTypeCallback(userdata,cbinfo)

    folderRadioActionName='selectFolderRadioButtonAction';
    systemRadioActionName='selectSystemRadioButtonAction';

    cloneDetectionUIObj=get_param(cbinfo.model.handle,'CloneDetectionUIObj');


    selectedName=userdata;

    if strcmp(selectedName,folderRadioActionName)

        cloneDetectionUIObj.isAcrossModel=true;
        clone_detection_app.internal.showFolderClonesDialogCallback(cbinfo);

    elseif strcmp(selectedName,systemRadioActionName)

        cloneDetectionUIObj.isAcrossModel=false;
        dlg=CloneDetectionUI.internal.util.findExistingDlg(cbinfo.model.handle,'FindAcrossFolders');

        if~isempty(dlg)
            delete(dlg)
        end

    end
end
