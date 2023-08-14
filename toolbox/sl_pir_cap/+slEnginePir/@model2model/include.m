function msg=include(m2mObj,aBlk)



    if isa(aBlk,'double')
        handle=aBlk;
    else
        handle=get_param(aBlk,'handle');
    end

    mdl=bdroot(getfullname(aBlk));
    if isKey(m2mObj.fExcludedBlks,mdl)
        excludedBlks=m2mObj.fExcludedBlks(mdl);
        idx=find([excludedBlks]==handle);
        if~isempty(idx)
            excludedBlks(idx)=[];
            m2mObj.fExcludedBlks(mdl)=excludedBlks;
        end
    else
        msg=[];
        return;
    end

    linkStatus=get_param(aBlk,'linkstatus');
    if strcmpi(linkStatus,'implicit')||strcmpi(linkStatus,'resolved')
        refBlk=get_param(aBlk,'ReferenceBlock');
        refBlkHandle=get_param(refBlk,'Handle');
        include(m2mObj,refBlkHandle);

        linkedCands=m2mObj.fLinkedCands(refBlkHandle);
        for cIdx=1:length(linkedCands)
            include(m2mObj,linkedCands(cIdx));
        end
    end
    msg=getfullname(handle);
end
