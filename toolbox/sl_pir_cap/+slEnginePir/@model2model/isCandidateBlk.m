function isCandidate=isCandidateBlk(m2mObj,aBlk)


    isCandidate=[];

    if isa(aBlk,'double')
        handle=aBlk;
    else
        handle=get_param(aBlk,'handle');
    end

    linkStatus=get_param(aBlk,'linkstatus');
    if strcmpi(linkStatus,'implicit')||strcmpi(linkStatus,'resolved')
        refBlk=get_param(aBlk,'ReferenceBlock');
        mdl=bdroot(aBlk);
    else
        mdl=bdroot(aBlk);
    end

    if isKey(m2mObj.fCandidateBlks,mdl)
        candidateBlks=m2mObj.fCandidateBlks(mdl);
    else
        return;
    end

    idx=~isempty(find([candidateBlks]==handle,1));

    if~isempty(idx)
        isCandidate=get_param(handle,'BlockType');
    end
end
