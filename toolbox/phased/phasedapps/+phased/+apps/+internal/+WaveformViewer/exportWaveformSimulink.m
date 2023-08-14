function exportWaveformSimulink(wave,comp)



    load_system('simulink')

    simulinkModel=new_system('','model');
    sys=get(simulinkModel,'Name');
    WaveformType=phased.apps.internal.WaveformViewer.getWaveformString(class(wave));
    CompressionType=phased.apps.internal.WaveformViewer.getWaveformString(class(comp));

    switch WaveformType
    case 'LinearFMWaveform'
        srcwaveform=[sys,'/Linear FM Waveform'];

        add_block('phasedwavlib/Linear FM Waveform',srcwaveform);
        if strcmp(wave.SweepDirection,getString(message('phased:apps:waveformapp:up')))
            sweepdir='Up';
        elseif strcmp(wave.SweepDirection,getString(message('phased:apps:waveformapp:dwn')))
            sweepdir='Down';
        end
        if strcmp(wave.SweepInterval,getString(message('phased:apps:waveformapp:positive')))
            sweepint='Positive';
        elseif strcmp(wave.SweepInterval,getString(message('phased:apps:waveformapp:symmetric')))
            sweepint='Symmetric';
        end
        if strcmp(wave.Envelope,getString(message('phased:apps:waveformapp:RectangularEnv')))
            envelope='Rectangular';
        elseif strcmp(wave.Envelope,getString(message('phased:apps:waveformapp:gaussian')))
            envelope='Gaussian';
        end

        set_param(srcwaveform,'SampleRate',sprintf('%d',wave.SampleRate));
        set_param(srcwaveform,'NumPulses',sprintf('%d',wave.NumPulses));
        set_param(srcwaveform,'PRF',sprintf('%d',wave.PRF));
        set_param(srcwaveform,'PulseWidth',sprintf('%d',wave.PulseWidth));
        set_param(srcwaveform,'SweepBandwidth',sprintf('%d',wave.SweepBandwidth));
        set_param(srcwaveform,'SweepDirection',sprintf('%s',sweepdir));
        set_param(srcwaveform,'SweepInterval',sprintf('%s',sweepint));
        set_param(srcwaveform,'Envelope',sprintf('%s',envelope));
        set_param(srcwaveform,'FrequencyOffset',sprintf('%g',wave.FrequencyOffset));
        set_param(srcwaveform,'Position',[50,50,200,100]);
    case 'RectangularWaveform'
        srcwaveform=[sys,'/Rectangular Waveform'];

        add_block('phasedwavlib/Rectangular Waveform',srcwaveform);

        set_param(srcwaveform,'SampleRate',sprintf('%d',wave.SampleRate));
        set_param(srcwaveform,'NumPulses',sprintf('%d',wave.NumPulses));
        set_param(srcwaveform,'PRF',sprintf('%d',wave.PRF));
        set_param(srcwaveform,'PulseWidth',sprintf('%d',wave.PulseWidth));
        set_param(srcwaveform,'FrequencyOffset',sprintf('%g',wave.FrequencyOffset));
    case 'SteppedFMWaveform'
        srcwaveform=[sys,'/Stepped FM Waveform'];

        add_block('phasedwavlib/Stepped FM Waveform',srcwaveform);

        set_param(srcwaveform,'SampleRate',sprintf('%d',wave.SampleRate));
        set_param(srcwaveform,'NumPulses',sprintf('%d',wave.NumPulses));
        set_param(srcwaveform,'PRF',sprintf('%d',wave.PRF));
        set_param(srcwaveform,'PulseWidth',sprintf('%d',wave.PulseWidth));
        set_param(srcwaveform,'FrequencyStep',sprintf('%d',wave.FrequencyStep));
        set_param(srcwaveform,'NumSteps',sprintf('%d',wave.NumSteps));
        set_param(srcwaveform,'SampleRate',sprintf('%d',wave.SampleRate));
        set_param(srcwaveform,'NumPulses',sprintf('%d',wave.NumPulses));
        set_param(srcwaveform,'PRF',sprintf('%d',wave.PRF));
        set_param(srcwaveform,'PulseWidth',sprintf('%d',wave.PulseWidth));
        set_param(srcwaveform,'FrequencyStep',sprintf('%d',wave.FrequencyStep));
        set_param(srcwaveform,'NumSteps',sprintf('%d',wave.NumSteps));
        set_param(srcwaveform,'FrequencyOffset',sprintf('%g',wave.FrequencyOffset));
        set_param(srcwaveform,'Position',[50,50,200,100]);
    case 'PhaseCodedWaveform'
        srcwaveform=[sys,'/Phase-Coded Waveform'];

        add_block('phasedwavlib/Phase-Coded Waveform',srcwaveform);
        if strcmp(wave.Code,getString(message('phased:apps:waveformapp:Barker')))
            code='Barker';
        elseif strcmp(wave.Code,getString(message('phased:apps:waveformapp:Frank')))
            code='Frank';
        elseif strcmp(wave.Code,getString(message('phased:apps:waveformapp:P1')))
            code='P1';
        elseif strcmp(wave.Code,getString(message('phased:apps:waveformapp:P2')))
            code='P2';
        elseif strcmp(wave.Code,getString(message('phased:apps:waveformapp:P3')))
            code='P3';
        elseif strcmp(wave.Code,getString(message('phased:apps:waveformapp:P4')))
            code='P4';
        elseif strcmp(wave.Code,getString(message('phased:apps:waveformapp:Px')))
            code='Px';
        elseif strcmp(wave.Code,getString(message('phased:apps:waveformapp:ZadoffChu')))
            code='Zadoff-Chu';
        end

        set_param(srcwaveform,'SampleRate',sprintf('%d',wave.SampleRate));
        set_param(srcwaveform,'NumPulses',sprintf('%d',wave.NumPulses));
        set_param(srcwaveform,'PRF',sprintf('%d',wave.PRF));
        set_param(srcwaveform,'ChipWidth',sprintf('%d',wave.ChipWidth));
        set_param(srcwaveform,'Code',sprintf('%s',code));
        set_param(srcwaveform,'Numchips',sprintf('%d',str2double(wave.NumChips)));
        if strcmp(code,'Zadoff-Chu')
            set_param(srcwaveform,'SequenceIndex',sprintf('%d',wave.SequenceIndex));
        end
        set_param(srcwaveform,'FrequencyOffset',sprintf('%g',wave.FrequencyOffset));
        set_param(srcwaveform,'Position',[50,30,200,100]);
    case 'FMCWWaveform'
        srcwaveform=[sys,'/FMCW Waveform'];

        add_block('phasedwavlib/FMCW Waveform',srcwaveform);
        if strcmp(wave.SweepDirection,getString(message('phased:apps:waveformapp:up')))
            sweepdir='Up';
        elseif strcmp(wave.SweepDirection,getString(message('phased:apps:waveformapp:dwn')))
            sweepdir='Down';
        elseif strcmp(wave.SweepDirection,getString(message('phased:apps:waveformapp:triangle')))
            sweepdir='Triangle';
        end
        if strcmp(wave.SweepInterval,getString(message('phased:apps:waveformapp:positive')))
            sweepint='Positive';
        elseif strcmp(wave.SweepInterval,getString(message('phased:apps:waveformapp:symmetric')))
            sweepint='Symmetric';
        end

        set_param(srcwaveform,'SampleRate',sprintf('%d',wave.SampleRate));
        set_param(srcwaveform,'NumSweeps',sprintf('%d',wave.NumSweeps));
        set_param(srcwaveform,'SweepTime',sprintf('%d',wave.SweepTime));
        set_param(srcwaveform,'SweepBandwidth',sprintf('%d',wave.SweepBandwidth));
        set_param(srcwaveform,'SweepDirection',sprintf('%s',sweepdir));
        set_param(srcwaveform,'SweepInterval',sprintf('%s',sweepint));
        set_param(srcwaveform,'Position',[50,30,200,100]);
    end
    switch CompressionType
    case 'MatchedFilter'
        srccompression=[sys,'/Matched Filter'];
        add_block('phaseddetectlib/Matched Filter',srccompression);
        set_param(srccompression,'CoefficientsSource','Input port');
        set_param(srccompression,'SpectrumWindow',sprintf('%s',comp.SpectrumWindow));
        if strcmp(comp.SpectrumWindow,'Taylor')
            set_param(srccompression,'SpectrumRange',sprintf('[%d %d]',comp.SpectrumRange(1),comp.SpectrumRange(2)));
            set_param(srccompression,'SideLobeAttenuation',sprintf('%d',comp.SideLobeAttenuation));
            set_param(srccompression,'Nbar',sprintf('%d',comp.Nbar));
        elseif strcmp(comp.SpectrumWindow,'Kaiser')
            set_param(srccompression,'SpectrumRange',sprintf('[%d %d]',comp.SpectrumRange(1),comp.SpectrumRange(2)));
            set_param(srccompression,'Beta',sprintf('%d',comp.Beta));
        elseif strcmp(comp.SpectrumWindow,'Chebyshev')
            set_param(srccompression,'SpectrumRange',sprintf('[%d %d]',comp.SpectrumRange(1),comp.SpectrumRange(2)));
            set_param(srccompression,'SideLobeAttenuation',sprintf('%d',comp.SideLobeAttenuation));
        elseif strcmp(comp.SpectrumWindow,'None')
        else
            set_param(srccompression,'SpectrumRange',sprintf('[%d %d]',comp.SpectrumRange(1),comp.SpectrumRange(2)));
        end
        set_param(srccompression,'Position',[285,30,385,90]);
        set_param(srcwaveform,'CoefficientsOutputPort','on');
    case 'StretchProcessor'
        uiwait(msgbox(getString(message('phased:apps:waveformapp:simulinkmessage','Range Window')),getString(message('phased:apps:waveformapp:SimulinkInfo'))));
        srccompression=[sys,'/Stretch Processor'];
        add_block('phaseddetectlib/Stretch Processor',srccompression);
        set_param(srccompression,'PulseWidth',sprintf('%d',wave.PulseWidth));
        set_param(srccompression,'PRFSource',sprintf('%s','Property'));
        set_param(srccompression,'PRF',sprintf('%d',wave.PRF));
        set_param(srccompression,'SweepSlope',sprintf('%d',wave.SweepBandwidth/wave.PulseWidth));
        set_param(srccompression,'PropagationSpeed',sprintf('%d',wave.PropagationSpeed));
        set_param(srccompression,'ReferenceRange',sprintf('%d',comp.ReferenceRange));
        set_param(srccompression,'RangeSpan',sprintf('%d',comp.RangeSpan));
        set_param(srccompression,'SweepInterval',sprintf('%s',sweepint));
    case 'Dechirp'
        srccompression=[sys,'/Dechirp'];
        add_block('phaseddetectlib/Dechirp Mixer',srccompression);
        set_param(srccompression,'Position',[420,46,595,104]);
    end

    if strcmp(WaveformType,'RectangularWaveform')
        add_line(sys,'Rectangular Waveform/2','Matched Filter/2');
    elseif strcmp(WaveformType,'LinearFMWaveform')
        if strcmp(CompressionType,'MatchedFilter')
            add_line(sys,'Linear FM Waveform/2','Matched Filter/2');
        end
    elseif strcmp(WaveformType,'PhaseCodedWaveform')
        add_line(sys,'Phase-Coded Waveform/2','Matched Filter/2');
    end

    set_param(srcwaveform,'Position',[50,30,165,90]);
    open_system(sys);
end