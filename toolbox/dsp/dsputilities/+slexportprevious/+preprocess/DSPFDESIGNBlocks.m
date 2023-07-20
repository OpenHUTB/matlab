function DSPFDESIGNBlocks(obj)










    verobj=obj.ver;



    if isR2011aOrEarlier(verobj)
        replaceByEmptysubsystem(obj,'Audio Weighting Filter');
        replaceByEmptysubsystem(obj,'Arbitrary Magnitude Filter');
    end


    if isR2009bOrEarlier(verobj)
        replaceByEmptysubsystem(obj,'Comb Filter');
    end


    if isR2009aOrEarlier(verobj)
        replaceByEmptysubsystem(obj,'Pulse Shaping Filter');
    end


    if isR2008bOrEarlier(verobj)
        replaceByEmptysubsystem(obj,'Lowpass Filter');
        replaceByEmptysubsystem(obj,'Highpass Filter');
        replaceByEmptysubsystem(obj,'Bandpass Filter');
        replaceByEmptysubsystem(obj,'Bandstop Filter');
        replaceByEmptysubsystem(obj,'Hilbert Filter');
        replaceByEmptysubsystem(obj,'Differentiator Filter');
        replaceByEmptysubsystem(obj,'Halfband Filter');
        replaceByEmptysubsystem(obj,'Nyquist Filter');
        replaceByEmptysubsystem(obj,'CIC Filter');
        replaceByEmptysubsystem(obj,'CIC Compensator');
        replaceByEmptysubsystem(obj,'Inverse Sinc Filter');
        replaceByEmptysubsystem(obj,'Octave Filter');
        replaceByEmptysubsystem(obj,'Peak/Notch Filter');
        replaceByEmptysubsystem(obj,'Parametric Equalizer');
    end

end

function replaceByEmptysubsystem(obj,SubsystemName)

    blocks=obj.findBlocksWithMaskType(SubsystemName,...
    'DialogController','fdesignblkfcn');
    for i=1:numel(blocks)
        obj.replaceWithEmptySubsystem(blocks{i});
    end

end