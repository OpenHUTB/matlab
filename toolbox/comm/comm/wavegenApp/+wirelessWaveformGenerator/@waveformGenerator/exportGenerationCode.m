function sw=exportGenerationCode(obj,sw)




    currDialog=obj.pParameters.CurrentDialog;
    addcr(sw,['%% ',getString(message('comm:waveformGenerator:GeneratingWaveform',obj.pCurrentWaveformType))]);

    if currDialog.sampleRateBeforeConfig

        addcr(sw,sprintf(['Fs = ',getSampleRateStr(currDialog),'; \t\t\t\t\t\t\t\t %% ',getString(message('comm:waveformGenerator:SampleRateTT'))]));
        addcr(sw,'');
    end

    addcr(sw,['% ',getString(message('comm:waveformGenerator:ConfigurationComment',obj.pCurrentWaveformType))]);
    addConfigCode(currDialog,sw);


    addInputCode(currDialog,sw);

    addcr(sw,['% ',getString(message('comm:waveformGenerator:GenerationSection'))]);
    addGenerationCode(currDialog,sw);
    addcr(sw,'');

    if~currDialog.sampleRateBeforeConfig

        addcr(sw,sprintf(['Fs = ',getSampleRateStr(currDialog),'; \t\t\t\t\t\t\t\t %% ',getString(message('comm:waveformGenerator:SampleRateTT'))]));
        addcr(sw,'');
    end


    dialogs=getDialogsPerColumn(currDialog);
    if any(cellfun(@(x)isa(x,'wirelessWaveformGenerator.FilteringDialog'),[dialogs{:}]))
        filterDialog=obj.pParameters.FilteringDialog;
        if~strcmp(filterDialog.Filtering,'None')
            addcr(sw,['% ',getString(message('comm:waveformGenerator:Filtering'))]);
            addFilteringCode(filterDialog,sw);
            addcr(sw,'');
        end
    end
end