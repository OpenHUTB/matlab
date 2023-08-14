function out=compressionProperties(wavProperties,compProperties)


    Waveform=phased.apps.internal.WaveformViewer.WaveformProperties(wavProperties);
    CompressionType=phased.apps.internal.WaveformViewer.getWaveformString(class(compProperties));
    switch CompressionType
    case 'MatchedFilter'
        Compression=phased.MatchedFilter;
        Compression.SpectrumWindow=compProperties.SpectrumWindow;
        coeff=getMatchedFilter(Waveform);
        Compression.Coefficients=coeff(:,1);
        if strcmp(Compression.SpectrumWindow,getString(message('phased:apps:waveformapp:Taylor')))
            Compression.SampleRate=wavProperties.SampleRate;
            Compression.SpectrumRange=compProperties.SpectrumRange;
            Compression.SidelobeAttenuation=compProperties.SideLobeAttenuation;
            Compression.Nbar=compProperties.Nbar;
        elseif strcmp(Compression.SpectrumWindow,getString(message('phased:apps:waveformapp:Kaiser')))
            Compression.SampleRate=wavProperties.SampleRate;
            Compression.SpectrumRange=compProperties.SpectrumRange;
            Compression.Beta=compProperties.Beta;
        elseif strcmp(Compression.SpectrumWindow,getString(message('phased:apps:waveformapp:Chebyshev')))
            Compression.SampleRate=wavProperties.SampleRate;
            Compression.SpectrumRange=compProperties.SpectrumRange;
            Compression.SidelobeAttenuation=compProperties.SideLobeAttenuation;
        elseif strcmp(Compression.SpectrumWindow,getString(message('phased:apps:waveformapp:None')))
        else
            Compression.SampleRate=wavProperties.SampleRate;
            Compression.SpectrumRange=compProperties.SpectrumRange;
        end
    case 'StretchProcessor'
        Compression=phased.StretchProcessor;
        Compression.SampleRate=wavProperties.SampleRate;
        Compression.PulseWidth=wavProperties.PulseWidth;
        Compression.PRFSource='Property';
        Compression.PRF=wavProperties.PRF;
        Compression.SweepSlope=wavProperties.SweepBandwidth/wavProperties.PulseWidth;
        Compression.SweepInterval=wavProperties.SweepInterval;
        Compression.PropagationSpeed=wavProperties.PropagationSpeed;
        Compression.ReferenceRange=compProperties.ReferenceRange;
        Compression.RangeSpan=compProperties.RangeSpan;
    case 'Dechirp'
        x=Waveform();
        Compression=dechirp(x,x);
    end
    out=Compression;
end