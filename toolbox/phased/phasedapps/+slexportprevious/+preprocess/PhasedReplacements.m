function PhasedReplacements(obj)




    if isR2022aOrEarlier(obj.ver)
        obj.removeBlocksOfType('ATIScopeBlock');
        obj.removeLibraryLinksTo(sprintf('phasedsnklib/Angle-Time Intensity Scope'));
    end

    if isR2021bOrEarlier(obj.ver)
        obj.removeBlocksOfType('RTIScopeBlock');
        obj.removeLibraryLinksTo(sprintf('phasedsnklib/Range-Time Intensity Scope'));
        obj.removeBlocksOfType('DTIScopeBlock');
        obj.removeLibraryLinksTo(sprintf('phasedsnklib/Doppler-Time Intensity Scope'));
    end

    if isR2019aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('phasedenvlib/Backscatter Bicyclist'));
        obj.removeLibraryLinksTo(sprintf('phaseddetectlib/DBSCAN Clustering'));
    end

    if isR2018bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('phasedenvlib/Backscatter Pedestrian');
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('phaseddetectlib/Range Angle Response');
        obj.removeLibraryLinksTo('phaseddoalib/Monopulse Feed');
        obj.removeLibraryLinksTo('phaseddoalib/Monopulse Estimator');
        obj.removeLibraryLinksTo('phaseddetectlib/Pulse Compression Library');
    end

    if isR2017bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('phasedwavlib/Pulse Waveform Library');
    end

    if isR2016bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('phaseddetectlib/Range Response');
        obj.removeLibraryLinksTo('phaseddetectlib/Range Estimator');
        obj.removeLibraryLinksTo('phaseddetectlib/Doppler Estimator');
        obj.removeLibraryLinksTo('phasedenvlib/Scattering MIMO Channel');
    end

    if isR2016aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('phasedenvlib/Wideband Two-Ray Channel');
        obj.removeLibraryLinksTo('phasedenvlib/Wideband Backscatter Radar Target');
        obj.removeLibraryLinksTo('phasedbflib/GSC Beamformer');
        obj.removeLibraryLinksTo('phaseddoalib/ULA MUSIC Spectrum');
        obj.removeLibraryLinksTo('phaseddoalib/MUSIC Spectrum');
        obj.removeLibraryLinksTo('phaseddetectlib/2-D CFAR Detector');
    end

    if isR2015bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('phasedenvlib/Backscatter Radar Target');
        obj.removeLibraryLinksTo('phasedenvlib/LOS Channel');
        obj.removeLibraryLinksTo('phasedenvlib/Wideband LOS Channel');
    end

    if isR2015aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('phasedbflib/Subband MVDR\nBeamformer'));
        obj.removeLibraryLinksTo('phaseddoalib/GCC DOA and TOA');
        obj.removeLibraryLinksTo('phasedenvlib/Two-Ray Channel');
        obj.removeLibraryLinksTo('phasedenvlib/Wideband Free Space');
        obj.removeLibraryLinksTo('phasedtxrxlib/Wideband Transmit Array');
    end

    if isR2014bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('phasedwavlib/MFSK Waveform');
    end

