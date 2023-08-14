function mfLink=createLinkToRequirement(this,linkSource,requirement,linkInfo)






    if isa(requirement,'slreq.data.Requirement')
        mfReq=this.getModelObj(requirement);
        reqDataObj=requirement;
    elseif isa(requirement,'slreq.datamodel.RequirementItem')
        mfReq=requirement;
        reqDataObj=this.wrap(mfReq);
    else
        error('ReqData.createLinkToRequirement(): 3rd argument must be a Requirement');
    end


    if this.isReservedReqSetName(mfReq.requirementSet.name)
        error('createLinkToRequirement() called for a non-persistent ReqSet');
    end





    try
        refPath=linkSource.artifact.artifactUri;
        destObj=this.createReferenceToReq(mfReq,refPath);
    catch ex
        throwAsCaller(ex);
    end

    mfLink=slreq.datamodel.Link(this.model);
    mfLink.source=linkSource;

    if~isempty(linkInfo)



        mfLink.description=linkInfo.description;


        if isfield(linkInfo,'keywords')&&~isempty(linkInfo.keywords)
            this.setKeywords(mfLink,linkInfo.keywords);
        end
    else


        mfLink.description='';


    end

    mfLink.revision=0;
    slreq.data.ReqData.updateModificationInfo(mfLink);


    mfLink.dest=destObj;

    dataLink=this.wrap(mfLink);
end
