function closeDlg(this,dlg)

    if~isempty(this.HighlightedBlock)
        hilite_system(this.HighlightedBlock,'none');
    end
    dlg.delete;
