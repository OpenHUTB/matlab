function editFilter(action)
    if strcmpi(action,'edit')
        dlg=slreq.gui.FilterEditor(true);
    else
        dlg=slreq.gui.newFilterView();
    end
    DAStudio.Dialog(dlg);
end