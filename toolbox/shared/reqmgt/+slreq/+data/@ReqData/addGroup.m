function group=addGroup(this,reqSet,artifactUri,domain)






    group=this.createGroup(artifactUri,domain);


    if isa(reqSet,'slreq.data.RequirementSet')
        reqSet=this.getModelObj(reqSet);
    end

    reqSet.groups.add(group);
end
