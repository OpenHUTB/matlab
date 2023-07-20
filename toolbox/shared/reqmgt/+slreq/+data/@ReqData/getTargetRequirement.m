function req=getTargetRequirement(this,linkObj)






    if~isa(linkObj,'slreq.data.Link')
        error('Invalid argument: expected slreq.data.Link object');
    end

    linkModelObj=linkObj.getModelObj();
    reqObj=linkModelObj.dest.requirement;
    if isempty(reqObj)
        req=slreq.data.Requirement.empty;
    else
        req=this.wrap(reqObj);
    end
end
