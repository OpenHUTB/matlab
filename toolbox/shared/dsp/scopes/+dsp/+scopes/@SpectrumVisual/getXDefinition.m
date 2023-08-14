function definition=getXDefinition(this)




    if isCCDFMode(this)
        definition.Type='DBAboveAverage';
        definition.Units='';
        definition.Multiplier=1;
    else
        definition.Type='Freq';
        definition.Units=[this.Plotter.FrequencyUnitsDisplay,'Hz'];
        definition.Multiplier=this.Plotter.FrequencyMultiplier;
    end
end
