
function AudioReplacements(obj)

    if isReleaseOrEarlier(obj.ver,'R2022a')
        obj.removeLibraryLinksTo('audioai/OpenL3 Embeddings');
        obj.removeLibraryLinksTo('audioai/OpenL3 Preprocess');
        obj.removeLibraryLinksTo('audioai/OpenL3');
        obj.removeLibraryLinksTo('audiofeatures/Audio Delta');
        obj.removeLibraryLinksTo('audiofeatures/Cepstral Coefficients');
        obj.removeLibraryLinksTo('audiofeatures/MFCC');
    end
    if isR2021bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('audioai/VGGish Embeddings');
        obj.removeLibraryLinksTo('audioai/VGGish Preprocess');
        obj.removeLibraryLinksTo('audioai/VGGish');
        obj.removeLibraryLinksTo('audiofilters/Shelving Filter');
        obj.removeLibraryLinksTo('audiofeatures/Design Auditory Filter Bank');
        obj.removeLibraryLinksTo('audiofeatures/Auditory Spectrogram');
        obj.removeLibraryLinksTo('audiofeatures/Design Mel Filter Bank');
        obj.removeLibraryLinksTo('audiofeatures/Mel Spectrogram');
    end
    if isR2021aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('audiofilters/Gammatone Filter Bank');
        obj.removeLibraryLinksTo('audioai/Sound Classifier');
        obj.removeLibraryLinksTo('audioai/YAMNet Preprocess');
        obj.removeLibraryLinksTo('audioai/YAMNet');
        obj.removeLibraryLinksTo('audiofilters/Multiband Parametric EQ');
    end
    if isR2020bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('audiofilters/Octave Filter Bank');
    end

    if isR2019bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('audiosources/Wavetable Synthesizer');
        obj.removeLibraryLinksTo('audiosources/Audio Oscillator');
    end

    if isR2018bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('audiofilters/Single-Band Parametric EQ');
    end

    if isR2017aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('audiofilters/Graphic EQ');
        obj.removeLibraryLinksTo('audiomeasurements/Cepstral Feature Extractor');
        obj.removeLibraryLinksTo('audiomeasurements/Voice Activity Detector');
    end

    if isR2016aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('audiofilters/Weighting Filter');
        obj.removeLibraryLinksTo('audiofilters/Octave Filter');
        obj.removeLibraryLinksTo('audiomeasurements/Loudness Meter');
    end

    if isR2015bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('audiodynamicrange/Compressor');
        obj.removeLibraryLinksTo('audiodynamicrange/Limiter');
        obj.removeLibraryLinksTo('audiodynamicrange/Expander');
        obj.removeLibraryLinksTo('audiodynamicrange/Noise Gate');
        obj.removeLibraryLinksTo('audioeffects/Reverberator');
        obj.removeLibraryLinksTo('audiofilters/Crossover Filter');
        obj.removeLibraryLinksTo(sprintf('audiosources/Audio Device\nReader'));
        obj.removeLibraryLinksTo(sprintf('audiosinks/Audio Device\nWriter'));
    end

