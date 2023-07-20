



function reqSetObj=createSpecialReqSet(this,name)






    reqSet=this.addRequirementSet(name);
    reqSetObj=this.wrap(reqSet);
end
