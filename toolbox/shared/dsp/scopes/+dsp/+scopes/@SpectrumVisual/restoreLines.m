function restoreLines(this)



    if~this.NeedToRestoreLines
        return
    end
    this.NeedToRestoreLines=false;
    hPlotter=this.Plotter;

    hPlotter.ChannelNamesChangedListener=@()onChannelNamesChanged(this);
    hPlotter.ChannelVisibilityChangedListener=@()onChannelVisibilityChanged(this);
    hPlotter.NormalTraceFlag=getPropertyValue(this,'NormalTrace');
    hPlotter.MaxHoldTraceFlag=~isCCDFMode(this)&&getPropertyValue(this,'MaxHoldTrace');
    hPlotter.MinHoldTraceFlag=~isCCDFMode(this)&&getPropertyValue(this,'MinHoldTrace');
    this.Lines=[hPlotter.Lines,hPlotter.MaxHoldTraceLines,hPlotter.MinHoldTraceLines];

    hPlotter.SpectralMaskVisibility=this.MaskSpecificationObject.EnabledMasks;
    notify(this,'DisplayUpdated');
end
