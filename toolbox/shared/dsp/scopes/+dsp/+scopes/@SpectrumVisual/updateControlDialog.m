function updateControlDialog(this,dlgName)




    if strcmp(dlgName,'SpectrumSettings')
        dlg=getSpectrumSettingsDialog(this);
    else
        dlg=getSpectralMaskDialog(this);
    end
    if~isempty(dlg)
        hAxes=this.Axes(1,1);
        fg=get(hAxes,'XColor');
        if~isempty(fg)
            set(dlg.ContentPanel,'ForegroundColor',fg);
        end
    end
end
