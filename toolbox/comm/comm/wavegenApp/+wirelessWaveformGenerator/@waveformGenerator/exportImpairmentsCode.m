function sw=exportImpairmentsCode(obj,sw)




    if obj.pImpairBtn.Value
        addcr(sw,['%% ',getString(message('comm:waveformGenerator:ImpairTitle'))]);

        impairs=obj.pParameters.ImpairDialog;

        if impairs.MemNonlinEnabled
            addcr(sw,['% ',getString(message('comm:waveformGenerator:MemNonlinEnabled'))]);
            addcr(sw,sprintf(['nonlin = comm.MemorylessNonlinearity(\t''LinearGain'', \t\t',impairs.LinearGainGUI.(impairs.EditValue),', ...']));
            addcr(sw,sprintf(['\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t''IIP3'', \t\t\t\t\t',impairs.IIP3GUI.(impairs.EditValue),', ...']));
            addcr(sw,sprintf(['\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t''AMPMConversion'', ',impairs.AMPMConversionGUI.(impairs.EditValue),');']));
            addcr(sw,'waveform = nonlin(complex(waveform));');
            addcr(sw,'');
        end

        if impairs.IQImbalanceEnabled
            addcr(sw,['% ',getString(message('comm:waveformGenerator:IQImbalanceEnabled'))]);
            addcr(sw,['waveform = iqimbal(waveform, ',impairs.IQImbAmpGUI.(impairs.EditValue),', (180/pi)*',impairs.IQImbPhaseGUI.(impairs.EditValue),');']);
            addcr(sw,'');
        end

        if impairs.FrequencyOffsetEnabled
            addcr(sw,['% ',getString(message('comm:waveformGenerator:FrequencyOffsetEnabled'))]);
            addcr(sw,sprintf(['freqOff = comm.PhaseFrequencyOffset(''FrequencyOffset'', ',impairs.FrequencyOffsetGUI.(impairs.EditValue),', ...']));
            addcr(sw,sprintf('\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t''SampleRate'', \t\tFs);'));
            addcr(sw,'waveform = freqOff(waveform);');
            addcr(sw,'');
        end

        if impairs.PhaseNoiseEnabled
            addcr(sw,['% ',getString(message('comm:waveformGenerator:PhaseNoiseEnabled'))]);
            addcr(sw,sprintf(['phaseNoise = comm.PhaseNoise(''FrequencyOffset'', ',impairs.PhaseNoiseFrequenciesGUI.(impairs.EditValue),', ...']));
            addcr(sw,sprintf(['\t\t\t\t\t\t\t\t\t\t\t\t\t\t ''Level'', \t\t\t\t\t',impairs.PhaseNoiseLevelsGUI.(impairs.EditValue),', ...']));
            addcr(sw,sprintf('\t\t\t\t\t\t\t\t\t\t\t\t\t\t ''SampleRate'', \t\t\tFs);'));
            addcr(sw,'waveform = phaseNoise(waveform);');
            addcr(sw,'');
        end

        if impairs.PhaseOffsetEnabled
            addcr(sw,['% ',getString(message('comm:waveformGenerator:PhaseOffsetEnabled'))]);
            addcr(sw,['waveform = waveform * exp(1i*',impairs.PhaseOffsetGUI.(impairs.EditValue),');']);
            addcr(sw,'');
        end

        if impairs.DCOffsetEnabled
            addcr(sw,['% ',getString(message('comm:waveformGenerator:DCOffsetEnabled'))]);
            addcr(sw,['waveform = waveform + ',impairs.DCOffsetGUI.(impairs.EditValue),';']);
            addcr(sw,'');
        end

        if impairs.AWGNEnabled
            addcr(sw,['% ',getString(message('comm:waveformGenerator:AWGNEnabled'))]);
            addcr(sw,['waveform = awgn(waveform, ',impairs.SNRGUI.(impairs.EditValue),', ''measured'');']);
            addcr(sw,'');
        end
    end
end
