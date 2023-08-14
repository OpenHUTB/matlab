function setModifiedOn(this,dataReqSet,modifiedOn)
    if~isa(dataReqSet,'slreq.data.RequirementSet')
        error('Invalid argument');
    end

    if~isdatetime(modifiedOn)
        error('Invalid argument');
    end

    mfReqSet=this.getModelObj(dataReqSet);
    mfReqSet.modifiedOn=slreq.utils.getDateTime(modifiedOn,'Write');
end