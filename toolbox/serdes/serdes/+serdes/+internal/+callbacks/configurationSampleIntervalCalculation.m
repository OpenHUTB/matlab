




function configurationSampleIntervalCalculation(block)

    simStatus=get_param(bdroot(block),'SimulationStatus');
    if strcmp(simStatus,'stopped')

        if~strcmp(get_param(block,'SymbolTime'),'NaN')
            symbolTime=slResolve(get_param(block,'SymbolTime'),bdroot(block));
            samplesPerSymbol=get_param(block,'SamplesPerSymbol');

            calculatedSampleInterval=symbolTime/str2double(samplesPerSymbol);
            set_param(block,'SampleInterval',serdes.internal.callbacks.numberToEngString(calculatedSampleInterval));
        else
            set_param(block,'SampleInterval','NaN')
        end
    end
end
