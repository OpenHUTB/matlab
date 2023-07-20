function definition=getYDefinition(this)




    if isCCDFMode(this)
        definition.Type='Probability';
        definition.Units='%';
        definition.Multiplier=1;
    elseif isSpectrogramMode(this)
        definition.Type='Time';
        definition.Units=this.Plotter.TimeUnitsDisplay;
        definition.Multiplier=this.Plotter.TimeMultiplier;
    elseif strcmp(this.pSpectrumType,'Power')||strcmp(this.pViewType,'Spectrum and spectrogram')
        definition.Type='Power';
        definition.Units=this.pSpectrumUnits;
        definition.Multiplier=1;
    elseif strcmp(this.pSpectrumType,'RMS')
        definition.Type='RMS';
        definition.Units=this.pSpectrumUnits;
        definition.Multiplier=1;
    else
        definition.Type='PowerDensity';
        definition.Units=this.pSpectrumUnits;
        definition.Multiplier=1;
    end
end
