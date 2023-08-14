function tableValueChangedCallback(hMask,hDlg,nRow,nCol,value)%#ok<INUSL>






    hMask.taskMappingData{nRow+1,nCol+1}=value;
    assignType=message('codertarget:taskmap:ManuallyAssigned').getString();
    hMask.taskMappingData{nRow+1,nCol+2}=assignType;
end