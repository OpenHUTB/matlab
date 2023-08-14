function definition=getZDefinition(this)



    if isSpectrogramMode(this)
        definition.Type='Power';
        definition.Units=this.pSpectrumUnits;
        definition.Multiplier=1;
    else
        definition.Type='Z';
        definition.Units='';
        definition.Multiplier=1;
    end
end
