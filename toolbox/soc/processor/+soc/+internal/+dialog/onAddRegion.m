function onAddRegion(hMask,hDlg)




    [nRows,~]=size(hMask.taskDurationData);
    if isequal(nRows,5)
        return;
    end
    hMask.taskDurationData=...
    [hMask.taskDurationData;{'0','1e-06','0','1e-06','1e-06'}];
    soc.internal.dialog.updateTaskDurationData(hMask);
    hDlg.enableApplyButton(true);
end