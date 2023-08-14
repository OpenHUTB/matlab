function linkedCandBlk=checkLinkStatusAndRegister(m2mObj,aCandidateBlk)



    linkedCandBlk=aCandidateBlk;
    linkStatus=get_param(aCandidateBlk.Handle,'linkstatus');
    if strcmpi(linkStatus,'implicit')||strcmpi(linkStatus,'resolved')
        linkedBlk=aCandidateBlk.Handle;
        while~strcmpi(linkStatus,'resolved')
            linkedBlk=get_param(linkedBlk,'parent');
            linkStatus=get_param(linkedBlk,'linkstatus');
        end
        linkData=get_param(linkedBlk,'LinkData');
        if isempty(linkData)
            refBlk=get_param(aCandidateBlk.Handle,'ReferenceBlock');
            refBlkHandle=get_param(refBlk,'handle');
            candBlkHandle=aCandidateBlk.Handle;
            if isKey(m2mObj.fLinkedCands,refBlkHandle)
                m2mObj.fLinkedCands(refBlkHandle)=unique([m2mObj.fLinkedCands(refBlkHandle),candBlkHandle]);
                if isKey(m2mObj.fInvalidCandidates,aCandidateBlk.Model)
                    m2mObj.fInvalidCandidates(aCandidateBlk.Model)=[m2mObj.fInvalidCandidates(aCandidateBlk.Model),candBlkHandle];
                else
                    m2mObj.fInvalidCandidates(aCandidateBlk.Model)=candBlkHandle;
                end
            else
                m2mObj.fLinkedCands(refBlkHandle)=candBlkHandle;
            end
            linkedCandBlk.Model=bdroot(refBlk);
            linkedCandBlk.Handle=refBlkHandle;
        end
    end
end
