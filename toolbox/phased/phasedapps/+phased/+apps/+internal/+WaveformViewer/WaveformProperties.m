function out=WaveformProperties(Properties)



    WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(Properties));
    switch WaveformType
    case 'LinearFMWaveform'
        Waveform=phased.LinearFMWaveform;
        Waveform.SampleRate=Properties.SampleRate;
        Waveform.PulseWidth=Properties.PulseWidth;
        Waveform.SweepBandwidth=Properties.SweepBandwidth;
        if strcmp(Properties.SweepDirection,getString(message('phased:apps:waveformapp:up')))
            Waveform.SweepDirection='Up';
        elseif strcmp(Properties.SweepDirection,getString(message('phased:apps:waveformapp:dwn')))
            Waveform.SweepDirection='Down';
        end
        if strcmp(Properties.SweepInterval,getString(message('phased:apps:waveformapp:positive')))
            Waveform.SweepInterval='Positive';
        elseif strcmp(Properties.SweepInterval,getString(message('phased:apps:waveformapp:symmetric')))
            Waveform.SweepInterval='Symmetric';
        end
        if strcmp(Properties.Envelope,getString(message('phased:apps:waveformapp:RectangularEnv')))
            Waveform.Envelope='Rectangular';
        elseif strcmp(Properties.Envelope,getString(message('phased:apps:waveformapp:gaussian')))
            Waveform.Envelope='Gaussian';
        end
        Waveform.NumPulses=Properties.NumPulses;
        Waveform.PRF=Properties.PRF;
        Waveform.FrequencyOffset=Properties.FrequencyOffset;
    case 'RectangularWaveform'
        Waveform=phased.RectangularWaveform;
        Waveform.SampleRate=Properties.SampleRate;
        Waveform.PulseWidth=Properties.PulseWidth;
        Waveform.NumPulses=Properties.NumPulses;
        Waveform.PRF=Properties.PRF;
        Waveform.FrequencyOffset=Properties.FrequencyOffset;
    case 'SteppedFMWaveform'
        Waveform=phased.SteppedFMWaveform;
        Waveform.SampleRate=Properties.SampleRate;
        Waveform.PulseWidth=Properties.PulseWidth;
        Waveform.NumSteps=Properties.NumSteps;
        Waveform.FrequencyStep=Properties.FrequencyStep;
        Waveform.NumPulses=Properties.NumPulses;
        Waveform.PRF=Properties.PRF;
        Waveform.FrequencyOffset=Properties.FrequencyOffset;
    case 'PhaseCodedWaveform'
        Waveform=phased.PhaseCodedWaveform;
        Waveform.SampleRate=Properties.SampleRate;
        Waveform.ChipWidth=Properties.ChipWidth;
        if strcmp(Properties.Code,getString(message('phased:apps:waveformapp:Barker')))
            Waveform.Code='Barker';
        elseif strcmp(Properties.Code,getString(message('phased:apps:waveformapp:Frank')))
            Waveform.Code='Frank';
        elseif strcmp(Properties.Code,getString(message('phased:apps:waveformapp:P1')))
            Waveform.Code='P1';
        elseif strcmp(Properties.Code,getString(message('phased:apps:waveformapp:P2')))
            Waveform.Code='P2';
        elseif strcmp(Properties.Code,getString(message('phased:apps:waveformapp:P3')))
            Waveform.Code='P3';
        elseif strcmp(Properties.Code,getString(message('phased:apps:waveformapp:P4')))
            Waveform.Code='P4';
        elseif strcmp(Properties.Code,getString(message('phased:apps:waveformapp:Px')))
            Waveform.Code='Px';
        elseif strcmp(Properties.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
            Waveform.Code='Zadoff-Chu';
        end
        Waveform.NumChips=str2double(Properties.NumChips);
        Waveform.NumPulses=Properties.NumPulses;
        Waveform.PRF=Properties.PRF;
        if strcmp(Properties.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
            Waveform.SequenceIndex=Properties.SequenceIndex;
        end
        Waveform.FrequencyOffset=Properties.FrequencyOffset;
    case 'FMCWWaveform'
        Waveform=phased.FMCWWaveform;
        Waveform.SampleRate=Properties.SampleRate;
        Waveform.SweepTime=Properties.SweepTime;
        Waveform.SweepBandwidth=Properties.SweepBandwidth;
        if strcmp(Properties.SweepDirection,getString(message('phased:apps:waveformapp:up')))
            Waveform.SweepDirection='Up';
        elseif strcmp(Properties.SweepDirection,getString(message('phased:apps:waveformapp:dwn')))
            Waveform.SweepDirection='Down';
        elseif strcmp(Properties.SweepDirection,getString(message('phased:apps:waveformapp:triangle')))
            Waveform.SweepDirection='Triangle';
        end
        if strcmp(Properties.SweepInterval,getString(message('phased:apps:waveformapp:positive')))
            Waveform.SweepInterval='Positive';
        elseif strcmp(Properties.SweepInterval,getString(message('phased:apps:waveformapp:symmetric')))
            Waveform.SweepInterval='Symmetric';
        end
        Waveform.NumSweeps=Properties.NumSweeps;
    end
    out=Waveform;
end