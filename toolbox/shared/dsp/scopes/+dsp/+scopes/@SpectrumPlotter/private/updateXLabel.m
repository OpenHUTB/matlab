function updateXLabel(this)




    xLabel=this.privXLabel;
    if isempty(xLabel)
        xLabel{1,1}=getString(message('dspshared:SpectrumAnalyzer:FrequencyXLabelWithUnits',this.FrequencyUnitsDisplay));
        xLabel{1,2}=getString(message('dspshared:SpectrumAnalyzer:FrequencyXLabelWithUnits',this.FrequencyUnitsDisplay));
        if strcmp(this.PlotMode,'Spectrogram')

            xLabel{1,1}='';
        elseif strcmp(this.PlotMode,'Spectrum')

            xLabel{1,2}='';
        else

            xLabel{1,1}=getString(message('dspshared:SpectrumAnalyzer:FrequencyXLabelWithUnits',this.FrequencyUnitsDisplay));
            xLabel{1,2}=getString(message('dspshared:SpectrumAnalyzer:FrequencyXLabelWithUnits',this.FrequencyUnitsDisplay));
        end
    end
    if this.CCDFMode

        xLabel{1,1}=getString(message('dspshared:SpectrumAnalyzer:CCDFXLabel'));
        xLabel{1,2}='';
    end

    for idx=1:length(this.Axes)
        if~strcmp(this.Axes(idx).XLabel.String,xLabel{idx})
            this.Axes(idx).XLabel.String=xLabel{idx};
        end
    end

end
