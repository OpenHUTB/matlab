function CommReplacements(obj)

    if isR2022aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commrflib2/Sample-Rate Match');
    end

    if isR2021aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commrflib2/Multiband Combiner');
    end

    if isR2019bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('rfideal_library/Amplifier');
    end

    if isR2018bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commrfcorlib/DPD');
        obj.removeLibraryLinksTo(sprintf('commrfcorlib/DPD\nCoefficient Estimator'));
        obj.removeLibraryLinksTo('commeq3/Linear Equalizer');
        obj.removeLibraryLinksTo(sprintf('commeq3/Decision Feedback\nEqualizer'));
    end

    if isR2017bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commdigbbndapm/M-APSK\nModulator Baseband');
        obj.removeLibraryLinksTo('commdigbbndapm/M-APSK\nDemodulator Baseband');
        obj.removeLibraryLinksTo('commdigbbndapm/DVBS-APSK\nModulator Baseband');
        obj.removeLibraryLinksTo('commdigbbndapm/DVBS-APSK\nDemodulator Baseband');
        obj.removeLibraryLinksTo('commdigbbndam3/MIL-188 QAM\nModulator Baseband');
        obj.removeLibraryLinksTo('commdigbbndam3/MIL-188 QAM\nDemodulator Baseband');
        obj.removeLibraryLinksTo('commblkcod2/TPC Encoder');
        obj.removeLibraryLinksTo('commblkcod2/TPC Decoder');
    end

    if isR2016aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commsource2/Baseband File Reader');
        obj.removeLibraryLinksTo('commsink2/Baseband File Writer');
        obj.removeLibraryLinksTo('commsync2/Preamble Detector');
    end

    if isR2015aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commsync2/Coarse Frequency\nCompensator');
    end

    if isR2014bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commphrec2/Carrier Synchronizer');
        obj.removeLibraryLinksTo('commanabbnd3/FM\nModulator\nBaseband');
        obj.removeLibraryLinksTo('commanabbnd3/FM\nDemodulator\nBaseband');
        obj.removeLibraryLinksTo('commanabbnd3/FM Broadcast\nModulator\nBaseband');
        obj.removeLibraryLinksTo('commanabbnd3/FM Broadcast\nDemodulator\nBaseband');
        obj.removeLibraryLinksTo('commsync2/Symbol Synchronizer');
    end

    if isR2014aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commrfcorlib/I//Q Imbalance Compensator');
        obj.removeLibraryLinksTo(sprintf('commrfcorlib/I//Q Compensator\nCoefficient to Imbalance'));
        obj.removeLibraryLinksTo(sprintf('commrfcorlib/I//Q Imbalance to\nCompensator Coefficient'));
    end

    if isR2013bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commofdm/OFDM Demodulator');
        obj.removeLibraryLinksTo('commofdm/OFDM Modulator');
    end

    if isR2013aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('commchan3/MIMO Channel');
        obj.removeLibraryLinksTo('commmimo/Sphere Decoder');
    end
