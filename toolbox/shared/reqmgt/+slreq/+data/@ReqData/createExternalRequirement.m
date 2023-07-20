function req=createExternalRequirement(this,reqInfo)






    req=slreq.datamodel.ExternalRequirement(this.model);


    req.isLocked=true;

    req.artifactId=reqInfo.artifactId;
    if isempty(reqInfo.id)
        req.customId=reqInfo.artifactId;
    else
        req.customId=reqInfo.id;
    end
    req.summary=reqInfo.summary;
    req.description=reqInfo.description;
    if isfield(reqInfo,'rationale')
        req.rationale=reqInfo.rationale;
    end
    if isfield(reqInfo,'keywords')
        this.setKeywords(req,reqInfo.keywords);
    end
    if isfield(reqInfo,'typeName')
        req.typeName=reqInfo.typeName;
    end

    req.revision=0;




    if isfield(reqInfo,'modifiedOn')
        req.modifiedOn=reqInfo.modifiedOn;
    else
        req.modifiedOn=datetime('now','TimeZone','UTC');
    end
    if isfield(reqInfo,'modifiedBy')
        req.modifiedBy=reqInfo.modifiedBy;
    end
    if isfield(reqInfo,'createdOn')
        req.createdOn=reqInfo.createdOn;
    else
        req.createdOn=datetime('now','TimeZone','UTC');
    end
    if isfield(reqInfo,'createdBy')
        req.createdBy=reqInfo.createdBy;
    end


    if isfield(reqInfo,'synchronizedOn')

        req.synchronizedOn=reqInfo.synchronizedOn;
    else
        req.synchronizedOn=datetime('now','TimeZone','UTC');
    end
end
