function searchClear(h)



    dlg=h.Dialog;
    dlg.setWidgetValue('searchInput','');
    h.SearchStr='';
    h.IsConvertedChecked=true;
    h.IsRestoredChecked=true;
    h.IsSkippedChecked=true;
    h.IsFailedChecked=true;

    h.setDlg;
