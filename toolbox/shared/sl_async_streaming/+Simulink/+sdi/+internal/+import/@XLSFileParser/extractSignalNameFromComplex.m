function sigName=extractSignalNameFromComplex(this,complexSigName)
    realInd=strfind(lower(complexSigName),this.REAL_PART_STR);
    compInd=strfind(lower(complexSigName),this.IMAG_PART_STR);
    if~isempty(realInd)
        lastRealInd=realInd(end);
        sigName=strtrim(complexSigName(1:lastRealInd-1));
    elseif~isempty(compInd)
        lastCompInd=compInd(end);
        sigName=strtrim(complexSigName(1:lastCompInd-1));
    end
end