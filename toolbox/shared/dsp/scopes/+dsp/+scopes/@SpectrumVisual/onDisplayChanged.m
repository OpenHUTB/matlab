function onDisplayChanged(this)



    storeAllLineProperties(this.Plotter);
    updateControlDialog(this,'SpectrumSettings');
    updateControlDialog(this,'SpectralMask');

    updateSpanReadOut(this);
    updateSamplesPerUpdateMessage(this);
    updateNoDataAvailableMessage(this);
end
