function dlg=getSpectralMaskDialog(this)





    dlg=[];
    if~isempty(this.DialogMgr)
        dlgName=getString(message('dspshared:SpectrumAnalyzer:SpectralMask'));
        dlgObjectMain=findobj(this.DialogMgr.Dialogs,'Name',dlgName);
        if~isempty(dlgObjectMain)
            dlg=dlgObjectMain.DialogContent;
        end
    end
end
