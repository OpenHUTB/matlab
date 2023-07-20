function req=createRequirement(this,reqInfo)






    req=slreq.datamodel.MwRequirement(this.model);


    req.isLocked=false;

    req.customId=reqInfo.id;
    req.summary=reqInfo.summary;
    req.description=reqInfo.description;

    if isfield(reqInfo,'rationale')
        req.rationale=reqInfo.rationale;
    end
    if isfield(reqInfo,'keywords')
        this.setKeywords(req,reqInfo.keywords);
    end

    if isfield(reqInfo,'descriptionEditorType')
        req.descriptionEditorType=reqInfo.descriptionEditorType;
    end

    if isfield(reqInfo,'rationaleEditorType')
        req.rationaleEditorType=reqInfo.rationaleEditorType;
    end

    if isfield(reqInfo,'typeName')
        req.typeName=reqInfo.typeName;
    end

    req.revision=0;
    slreq.data.ReqData.updateModificationInfo(req);
end
