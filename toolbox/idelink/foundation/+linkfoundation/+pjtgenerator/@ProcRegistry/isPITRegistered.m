function ret=isPITRegistered(reg,pitFile)





    pitFile=convertStringsToChars(pitFile);

    ret=1;

    pitIdx=getPITRegIdx(reg,pitFile);
    if isempty(pitIdx)
        ret=0;
    end
end
