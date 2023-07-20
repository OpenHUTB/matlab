function cacheImpairments(obj)




    impairs=obj.pParameters.ImpairDialog;
    str=struct;

    if isempty(obj.pParameters.ImpairDialog)
        return;
    end

    if impairs.AWGNEnabled
        str.SNR=impairs.SNR;
    end

    if impairs.PhaseNoiseEnabled
        str.PhaseNoise.Levels=impairs.PhaseNoiseLevels;
        str.PhaseNoise.Frequencies=impairs.PhaseNoiseFrequencies;
    end

    if impairs.PhaseOffsetEnabled
        str.PhaseOffset=impairs.PhaseOffset;
    end

    if impairs.FrequencyOffsetEnabled
        str.FrequencyOffset=impairs.FrequencyOffset;
    end

    if impairs.DCOffsetEnabled
        str.DCOffset=impairs.DCOffset;
    end

    if impairs.IQImbalanceEnabled
        str.IQImbalance.AmplitudeImbalance=impairs.IQImbAmp;
        str.IQImbalance.PhaseImbalance=impairs.IQImbPhase;
    end

    if impairs.MemNonlinEnabled
        str.MemorylessNonLinearity.LinearGain=impairs.LinearGain;
        str.MemorylessNonLinearity.IIP3=impairs.IIP3;
        str.MemorylessNonLinearity.AMPMConversion=impairs.AMPMConversion;
    end

    obj.pGenerationImpairments=str;


