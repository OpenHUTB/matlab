function impaired=impairWaveform(obj,waveform,Fs)




    impaired=waveform;

    if~obj.pImpairBtn.Value
        return;
    end

    impairs=obj.pParameters.ImpairDialog;

    if impairs.MemNonlinEnabled
        if isempty(obj.pNonlinearity)
            obj.pNonlinearity=comm.MemorylessNonlinearity;
        end
        if(obj.pNonlinearity.LinearGain~=impairs.LinearGain)||...
            (obj.pNonlinearity.IIP3~=impairs.IIP3)||...
            (obj.pNonlinearity.AMPMConversion~=impairs.AMPMConversion)

            release(obj.pNonlinearity);
            obj.pNonlinearity.LinearGain=impairs.LinearGain;
            obj.pNonlinearity.IIP3=impairs.IIP3;
            obj.pNonlinearity.AMPMConversion=impairs.AMPMConversion;
        end
        for idx=1:size(impaired,2)
            impaired(:,idx)=obj.pNonlinearity(complex(impaired(:,idx)));
            reset(obj.pNonlinearity);
        end
    end

    if impairs.IQImbalanceEnabled
        impaired=iqimbal(impaired,impairs.IQImbAmp,impairs.IQImbPhase);
    end

    if impairs.FrequencyOffsetEnabled
        if isempty(obj.pFrequencyOffset)
            obj.pFrequencyOffset=comm.PhaseFrequencyOffset('SampleRate',Fs);
        end
        if(obj.pFrequencyOffset.FrequencyOffset~=impairs.FrequencyOffset)||...
            (obj.pFrequencyOffset.SampleRate~=Fs)
            release(obj.pFrequencyOffset);
            obj.pFrequencyOffset.FrequencyOffset=impairs.FrequencyOffset;
            obj.pFrequencyOffset.SampleRate=Fs;
        end
        impaired=obj.pFrequencyOffset(impaired);
    end

    if impairs.PhaseNoiseEnabled
        if isempty(obj.pPhaseNoise)
            obj.pPhaseNoise=comm.PhaseNoise('SampleRate',Fs);
        end
        if(any(obj.pPhaseNoise.Level-impairs.PhaseNoiseLevels)>eps)||...
            (any(obj.pPhaseNoise.FrequencyOffset-impairs.PhaseNoiseFrequencies)>eps)||...
            (obj.pPhaseNoise.SampleRate~=Fs)
            release(obj.pPhaseNoise);
            obj.pPhaseNoise.FrequencyOffset=impairs.PhaseNoiseFrequencies;
            obj.pPhaseNoise.Level=impairs.PhaseNoiseLevels;
            obj.pPhaseNoise.SampleRate=Fs;
        end
        for idx=1:size(impaired,2)
            impaired(:,idx)=obj.pPhaseNoise(complex(impaired(:,idx)));
            reset(obj.pPhaseNoise);
        end
    end

    if impairs.PhaseOffsetEnabled
        impaired=impaired*exp(1i*impairs.PhaseOffset);
    end

    if impairs.DCOffsetEnabled
        impaired=impaired+impairs.DCOffset;
    end

    if impairs.AWGNEnabled
        impaired=awgn(impaired,impairs.SNR,'measured');
    end

