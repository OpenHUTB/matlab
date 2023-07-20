function msg=exclude(m2mObj,aBlk)



    if isa(aBlk,'double')
        handle=aBlk;
    else
        handle=get_param(aBlk,'handle');
    end

    mdl=bdroot(getfullname(aBlk));
    if isKey(m2mObj.fExcludedBlks,mdl)
        m2mObj.fExcludedBlks(mdl)=unique([m2mObj.fExcludedBlks(mdl),handle]);
    else
        m2mObj.fExcludedBlks(mdl)=handle;
    end

    linkStatus=get_param(aBlk,'linkstatus');
    if strcmpi(linkStatus,'implicit')||strcmpi(linkStatus,'resolved')
        refBlk=get_param(aBlk,'ReferenceBlock');
        refBlkHandle=get_param(refBlk,'Handle');
        if isKey(m2mObj.fExcludedBlks,bdroot(refBlk))&&...
            ismember(refBlkHandle,m2mObj.fExcludedBlks(bdroot(refBlk)))
            return;
        end
        exclude(m2mObj,refBlkHandle);
    end

    if isKey(m2mObj.fLinkedCands,handle)
        linkedCands=m2mObj.fLinkedCands(handle);
        for cIdx=1:length(linkedCands)
            exclude(m2mObj,linkedCands(cIdx));
        end
    end

    msg=getfullname(handle);
end
