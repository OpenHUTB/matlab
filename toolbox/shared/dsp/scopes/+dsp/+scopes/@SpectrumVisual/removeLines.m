function removeLines(this)




    hPlotter=this.Plotter;
    hPlotter.ChannelNamesChangedListener=[];
    hPlotter.ChannelVisibilityChangedListener=[];
    this.NeedToRestoreLines=true;

    dlgObject=getSpectrumSettingsDialog(this);
    if~isempty(dlgObject)
        refreshDlgProp(dlgObject,'ChannelNumber');
    end
    this.Lines=[];
    hPlotter.NormalTraceFlag=false;
    hPlotter.MaxHoldTraceFlag=false;
    hPlotter.MinHoldTraceFlag=false;
    hPlotter.CCDFGaussianReferenceFlag=false;
    hPlotter.SpectralMaskVisibility='None';
    notify(this,'DisplayUpdated');
end
