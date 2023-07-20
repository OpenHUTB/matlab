
function rbSnapshotRF(userData,cbinfo,action)


    if~strcmp(class(cbinfo.uiObject),"Simulink.Record")
        return;
    end

    snapshot=get_param(cbinfo.uiObject.Handle,'Snapshot');
    snapshotArea=snapshot.area;
    switch snapshotArea
    case RecordBlkView.SnapshotArea.ENTIRE_PLOT
        if strcmp(userData,'EntirePlotArea')
            action.selected=1;
        end
    case RecordBlkView.SnapshotArea.SELECTED_PLOT
        if strcmp(userData,'SelectedPlotArea')
            action.selected=1;
        end
    end

    snapshotSendto=snapshot.sendTo;
    switch snapshotSendto
    case RecordBlkView.SnapshotSend.CLIPBOARD
        if strcmp(userData,'Clipboard')
            action.selected=1;
        end
    case RecordBlkView.SnapshotSend.IMAGEFILE
        if strcmp(userData,'ImageFile')
            action.selected=1;
        end
    case RecordBlkView.SnapshotSend.MATLABFIGURE
        if strcmp(userData,'MATLABFigure')
            action.selected=1;
        end
    end
end