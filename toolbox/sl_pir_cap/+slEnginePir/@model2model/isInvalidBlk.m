function isInvalid=isInvalidBlk(m2mObj,aBlk)


    if isa(aBlk,'double')
        handle=aBlk;
    else
        handle=get_param(aBlk,'handle');
    end

    mdl=bdroot(getfullname(handle));







    invalidBlks=[];
    if isKey(m2mObj.fInvalidCandidates,mdl)
        invalidBlks=m2mObj.fInvalidCandidates(mdl);
    else
        isInvalid=0;
        return;
    end

    idx=find([invalidBlks]==handle,1);
    if~isempty(idx)
        isInvalid=1;
    else
        isInvalid=0;
    end
end
