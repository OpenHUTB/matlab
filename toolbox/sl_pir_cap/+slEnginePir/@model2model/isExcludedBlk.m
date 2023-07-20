function isExcluded=isExcludedBlk(m2mObj,aBlk)


    if isa(aBlk,'double')
        handle=aBlk;
    else
        handle=get_param(aBlk,'handle');
    end

    mdl=bdroot(getfullname(handle));
    linkStatus=get_param(aBlk,'linkstatus');
    if strcmpi(linkStatus,'implicit')||strcmpi(linkStatus,'resolved')
        refBlk=get_param(aBlk,'ReferenceBlock');
        handle=get_param(refBlk,'handle');
        mdl=bdroot(refBlk);
    end

    excludedBlks=[];
    if isKey(m2mObj.fExcludedBlks,mdl)
        excludedBlks=m2mObj.fExcludedBlks(mdl);
    else
        isExcluded=0;
        return;
    end

    idx=find([excludedBlks]==handle,1);
    if~isempty(idx)
        isExcluded=1;
    else
        isExcluded=0;
    end
end
