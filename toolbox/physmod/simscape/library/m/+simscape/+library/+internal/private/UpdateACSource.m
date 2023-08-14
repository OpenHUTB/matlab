function UpdateACSource(block,h)








    reason='Copy redundant angular frequency parameter to new frequency parameter.';

    pvPair=simscape.library.internal.UpdateACSourcePVs(block);

    if isempty(pvPair)
        return;
    end

    if~(askToReplace(h,block))
        return;
    end

    funcSet=uSafeSetParam(h,block,pvPair{:});
    appendTransaction(h,block,reason,{funcSet});

end
