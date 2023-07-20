function onDeleteRegion(hMask,hDlg)




    [numRegions,~]=size(hMask.taskDurationData);
    if isequal(numRegions,1)
        return;
    end
    regionIdx=hMask.selectedTableRow;
    hMask.taskDurationData(regionIdx,:)=[];
    soc.internal.dialog.updateTaskDurationData(hMask);



    [newNumRegions,~]=size(hMask.taskDurationData);
    if regionIdx>newNumRegions,regionIdx=regionIdx-1;end
    hMask.selectedTableRow=regionIdx;
    hDlg.selectTableRow('taskDurationTable',regionIdx-1)
    hDlg.enableApplyButton(true);
end