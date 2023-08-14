function DSPReplacements(obj)




    if isReleaseOrEarlier(obj.ver,'R2022a')
        obj.removeLibraryLinksTo('dspfeatures/Wavelet Scattering');
    end

    if isR2020bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('dspstat3/Power Meter');
    end

    if isR2019aOrEarlier(obj.ver)
        obj.removeBlocksOfType('FIRSampleRateConverter');
    end

    if isR2017bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('dspmlti4/Complex Bandpass\nDecimator'));
        obj.removeLibraryLinksTo(sprintf('dspadpt3/Frequency-Domain\nAdaptive Filter'));
    end

    if isR2017aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('dspxfrm3/Zoom FFT');
        obj.removeLibraryLinksTo(sprintf('dsparch4/Frequency-Domain\nFIR Filter'));
    end

    if isR2016bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('dspmlti4/Channelizer');
        obj.removeLibraryLinksTo('dspmlti4/Channel Synthesizer');
        obj.removeLibraryLinksTo(sprintf('dspfdesign/Hampel\nFilter'));
        obj.removeLibraryLinksTo(sprintf('dsphdlfiltering/Discrete FIR Filter\nHDL Optimized'));
    end

    if isR2016aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('dspadpt3/LMS Update');
        obj.removeLibraryLinksTo(sprintf('dspstat3/Moving\nMinimum'));
        obj.removeLibraryLinksTo(sprintf('dspstat3/Moving\nMaximum'));
        obj.removeLibraryLinksTo(sprintf('dspstat3/Median\nFilter'));
        obj.removeLibraryLinksTo(sprintf('dspstat3/Moving\nAverage'));
        obj.removeLibraryLinksTo(sprintf('dspstat3/Moving\nRMS'));
        obj.removeLibraryLinksTo(sprintf('dspstat3/Moving\nVariance'));
        obj.removeLibraryLinksTo(sprintf('dspstat3/Moving\nStandard\nDeviation'));
        obj.removeLibraryLinksTo('dspsrcs4/Binary File Reader');
        obj.removeLibraryLinksTo('dspsnks4/Binary File Writer');
        obj.removeLibraryLinksTo('dsparch4/Allpass Filter');
    end

    if isR2015bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('dspfdesign/Differentiator Filter');
        obj.removeLibraryLinksTo(sprintf('dspsnks4/Audio Device\nWriter'));
    end

    if isR2015aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('dsphdlfiltering/FIR Rate Conversion\nHDL Optimized'));
        obj.removeLibraryLinksTo(sprintf('dspsigops/Sample-Rate\nConverter'));
        obj.removeLibraryLinksTo(sprintf('dspsigops/Farrow Rate\nConverter'));
        obj.removeLibraryLinksTo(sprintf('dspfdesign/FIR Halfband\nInterpolator'));
        obj.removeLibraryLinksTo(sprintf('dspfdesign/FIR Halfband\nDecimator'));
        obj.removeLibraryLinksTo(sprintf('dspfdesign/IIR Halfband\nInterpolator'));
        obj.removeLibraryLinksTo(sprintf('dspfdesign/IIR Halfband\nDecimator'));
        obj.removeLibraryLinksTo(sprintf('dspfdesign/CIC Compensation\nInterpolator'));
        obj.removeLibraryLinksTo(sprintf('dspfdesign/CIC Compensation\nDecimator'));
        obj.removeLibraryLinksTo('dspfdesign/Lowpass Filter');
        obj.removeLibraryLinksTo('dspfdesign/Highpass Filter');
        obj.removeLibraryLinksTo('dspspect3/Spectrum Estimator');
        obj.removeBlocksOfType('ArrayPlot');
    end

    if isR2014bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('dspfdesign/Variable Bandwidth\nFIR Filter'));
        obj.removeLibraryLinksTo(sprintf('dspfdesign/Variable Bandwidth\nIIR Filter'));
        obj.removeLibraryLinksTo('dspfdesign/Notch-Peak Filter');
        obj.removeLibraryLinksTo('dspfdesign/Parametric EQ Filter');
        obj.removeLibraryLinksTo(sprintf('dspspect3/Cross-Spectrum\nEstimator'));
        obj.removeLibraryLinksTo(sprintf('dspsigops/Digital\nDown-Converter'));
        obj.removeLibraryLinksTo(sprintf('dspsigops/Digital\nUp-Converter'));
        obj.removeLibraryLinksTo('dspsrcs4/Colored Noise');
    end

    if isR2014aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('dspsigops/Phase Extractor');
        obj.removeLibraryLinksTo(sprintf('dsphdlmathfun/Complex to Magnitude-Angle\nHDL Optimized'));
    end

    if isR2013bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('dspspect3/Discrete\nTransfer Function\nEstimator'));
        obj.removeLibraryLinksTo('dspsigops/DC Blocker');
        obj.removeLibraryLinksTo(sprintf('dsphdlxfrm/FFT\nHDL Optimized'));
        obj.removeLibraryLinksTo(sprintf('dsphdlxfrm/IFFT\nHDL Optimized'));
    end

    if isR2012bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('dsphdlsigops/NCO\nHDL Optimized'));
    end

    if isR2011bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('dspsrcs4/MIDI Controls');
    end

