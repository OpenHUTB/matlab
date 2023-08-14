function profiles=getAllProfiles(this,linkReqSet)



    if isa(linkReqSet,'slreq.data.RequirementSet')
        mflinkReqSet=this.getModelObj(linkReqSet);
    elseif isa(linkReqSet,'slreq.datamodel.RequirementSet')||...
        isa(linkReqSet,'slreq.datamodel.LinkSet')
        mflinkReqSet=linkReqSet;
    elseif isa(linkReqSet,'slreq.datamodel.Link')
        error('Stereotype for link is not supported yet');

    end

    profiles=mflinkReqSet.profiles;
end