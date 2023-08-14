function renameStereotypeAttribute(this,reqLink,oldName,newName)

    if isa(reqLink,'slreq.data.Requirement')||isa(reqLink,'slreq.data.Link')
        mfReqLink=this.getModelObj(reqLink);
    elseif isa(reqLink,'slreq.datamodel.RequirementItem')
        mfReqLink=reqLink;
    else

        return;
    end

    catt=mfReqLink.customAttributes.getByKey(oldName);
    if~isempty(catt)
        catt.name=newName;
    end
end