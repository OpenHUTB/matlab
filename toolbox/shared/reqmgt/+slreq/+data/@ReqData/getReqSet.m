function reqSetObj=getReqSet(this,rsname)






    reqSetObj=[];
    reqSet=this.findRequirementSet(rsname);
    if~isempty(reqSet)
        reqSetObj=this.wrap(reqSet);
    end
end
