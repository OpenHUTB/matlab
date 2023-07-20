function out=UpdateProperties(Waveform)



    WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(Waveform));
    switch WaveformType
    case 'LinearFMWaveform'
        WaveformUpdate=phased.apps.internal.WaveformViewer.LinearFMWaveform;
        WaveformUpdate.Name=Waveform.Name;
        WaveformUpdate.NumPulses=Waveform.NumPulses;
        WaveformUpdate.PRF=Waveform.PRF;
        WaveformUpdate.FrequencyOffset=Waveform.FrequencyOffset;
        WaveformUpdate.PropagationSpeed=Waveform.PropagationSpeed;
        WaveformUpdate.PulseWidth=Waveform.PulseWidth;
        WaveformUpdate.SweepBandwidth=Waveform.SweepBandwidth;
        WaveformUpdate.SweepDirection=Waveform.SweepDirection;
        WaveformUpdate.SweepInterval=Waveform.SweepInterval;
        WaveformUpdate.Envelope=Waveform.Envelope;
        WaveformUpdate.SampleRate=Waveform.SampleRate;
    case 'RectangularWaveform'
        WaveformUpdate=phased.apps.internal.WaveformViewer.RectangularWaveform;
        WaveformUpdate.Name=Waveform.Name;
        WaveformUpdate.NumPulses=Waveform.NumPulses;
        WaveformUpdate.PRF=Waveform.PRF;
        WaveformUpdate.FrequencyOffset=Waveform.FrequencyOffset;
        WaveformUpdate.PropagationSpeed=Waveform.PropagationSpeed;
        WaveformUpdate.PulseWidth=Waveform.PulseWidth;
        WaveformUpdate.SampleRate=Waveform.SampleRate;
    case 'SteppedFMWaveform'
        WaveformUpdate=phased.apps.internal.WaveformViewer.SteppedFMWaveform;
        WaveformUpdate.Name=Waveform.Name;
        WaveformUpdate.NumPulses=Waveform.NumPulses;
        WaveformUpdate.PRF=Waveform.PRF;
        WaveformUpdate.FrequencyOffset=Waveform.FrequencyOffset;
        WaveformUpdate.PropagationSpeed=Waveform.PropagationSpeed;
        WaveformUpdate.PulseWidth=Waveform.PulseWidth;
        WaveformUpdate.FrequencyStep=Waveform.FrequencyStep;
        WaveformUpdate.NumSteps=Waveform.NumSteps;
        WaveformUpdate.SampleRate=Waveform.SampleRate;

    case 'PhaseCodedWaveform'
        WaveformUpdate=phased.apps.internal.WaveformViewer.PhaseCodedWaveform;
        WaveformUpdate.Name=Waveform.Name;
        WaveformUpdate.NumPulses=Waveform.NumPulses;
        WaveformUpdate.PRF=Waveform.PRF;
        WaveformUpdate.FrequencyOffset=Waveform.FrequencyOffset;
        WaveformUpdate.PropagationSpeed=Waveform.PropagationSpeed;
        WaveformUpdate.Code=Waveform.Code;
        WaveformUpdate.ChipWidth=Waveform.ChipWidth;
        WaveformUpdate.NumChips=Waveform.NumChips;
        WaveformUpdate.SampleRate=Waveform.SampleRate;
        if strcmp(WaveformUpdate.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
            WaveformUpdate.SequenceIndex=Waveform.SequenceIndex;
        end
    case 'FMCWWaveform'
        WaveformUpdate=phased.apps.internal.WaveformViewer.FMCWWaveform;
        WaveformUpdate.Name=Waveform.Name;
        WaveformUpdate.NumSweeps=Waveform.NumSweeps;
        WaveformUpdate.SweepTime=Waveform.SweepTime;
        WaveformUpdate.SweepBandwidth=Waveform.SweepBandwidth;
        WaveformUpdate.SweepDirection=Waveform.SweepDirection;
        WaveformUpdate.SweepInterval=Waveform.SweepInterval;
        WaveformUpdate.PropagationSpeed=Waveform.PropagationSpeed;
        WaveformUpdate.SampleRate=Waveform.SampleRate;
    case 'MatchedFilter'
        WaveformUpdate=phased.apps.internal.WaveformViewer.MatchedFilter;
        WaveformUpdate.SpectrumWindow=Waveform.SpectrumWindow;
        WaveformUpdate.SpectrumRange=Waveform.SpectrumRange;
        if strcmp(WaveformUpdate.SpectrumWindow,'Taylor')
            WaveformUpdate.SideLobeAttenuation=Waveform.SideLobeAttenuation;
            WaveformUpdate.Nbar=Waveform.Nbar;
        elseif strcmp(WaveformUpdate.SpectrumWindow,'Chebyshev')
            WaveformUpdate.SideLobeAttenuation=Waveform.SideLobeAttenuation;
        elseif strcmp(WaveformUpdate.SpectrumWindow,'Kaiser')
            WaveformUpdate.Beta=Waveform.Beta;
        end
    case 'StretchProcessor'
        WaveformUpdate=phased.apps.internal.WaveformViewer.StretchProcessor;
        WaveformUpdate.RangeWindow=Waveform.RangeWindow;
        WaveformUpdate.ReferenceRange=Waveform.ReferenceRange;
        WaveformUpdate.RangeSpan=Waveform.RangeSpan;
        WaveformUpdate.RangeFFTLength=Waveform.RangeFFTLength;
        if strcmp(WaveformUpdate.RangeWindow,'Taylor')
            WaveformUpdate.SideLobeAttenuation=Waveform.SideLobeAttenuation;
            WaveformUpdate.Nbar=Waveform.Nbar;
        elseif strcmp(WaveformUpdate.RangeWindow,'Chebyshev')
            WaveformUpdate.SideLobeAttenuation=Waveform.SideLobeAttenuation;
        elseif strcmp(WaveformUpdate.RangeWindow,'Kaiser')
            WaveformUpdate.Beta=Waveform.Beta;
        end
    case 'Dechirp'
        WaveformUpdate=phased.apps.internal.WaveformViewer.Dechirp;
    end
    out=WaveformUpdate;
end