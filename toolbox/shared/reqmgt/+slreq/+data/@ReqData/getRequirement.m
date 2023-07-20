function dataReq=getRequirement(this,reqSet,numericID)






    modelReqSet=this.getModelObj(reqSet);
    req=modelReqSet.items{int32(numericID)};
    if~isempty(req)
        dataReq=this.wrap(req);
    else
        dataReq=slreq.data.Requirement.empty;
    end
end
