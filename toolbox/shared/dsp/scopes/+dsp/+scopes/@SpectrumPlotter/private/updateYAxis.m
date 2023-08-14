function updateYAxis(this)





    if this.CCDFMode
        updateCCDFYAxis(this);
    elseif strcmp(this.PlotMode,'Spectrogram')
        updateTimeUnits(this);
    elseif any(strcmp(this.PlotMode,'SpectrumAndSpectrogram'))
        updateTimeUnits(this);
        updateYLimits(this);
    else
        updateYLimits(this);
    end
    updateYLabel(this);
    updateYTickLabels(this);

end
