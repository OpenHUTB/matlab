function uniquefreqs=checkuniquefreqs(freqs)

    uniquefreqs=unique(freqs,'stable');

    if numel(uniquefreqs)~=numel(freqs)
        warning(message('antenna:antennaerrors:FreqsNotUnique'));
    end

end