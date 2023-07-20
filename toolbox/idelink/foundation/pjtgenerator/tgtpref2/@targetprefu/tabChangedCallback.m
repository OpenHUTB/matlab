function tabChangedCallback(hDlg,widTag,tabIdx)%#ok<INUSL>




    cs=hDlg.getDialogSource();
    cs.setProp('TargetResourceManagerActiveTab',tabIdx);
end
