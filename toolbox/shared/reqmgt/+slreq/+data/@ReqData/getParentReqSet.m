function reqSetObj=getParentReqSet(this,reqObj)






    if~isa(reqObj,'slreq.data.Requirement')
        error('Invalid argument: expected slreq.data.Requirement');
    end
    modelReqObj=this.getModelObj(reqObj);
    reqSetObj=this.wrap(modelReqObj.requirementSet);
end
