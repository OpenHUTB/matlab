function refreshReadouts(this)






    dlg=getSpectrumSettingsDialog(this);
    if~isempty(dlg)
        refreshPanel(dlg,'All')
    end

    updateSpanReadOut(this);
end
