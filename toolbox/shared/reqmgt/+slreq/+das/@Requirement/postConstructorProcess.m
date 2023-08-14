function postConstructorProcess(this,req,parent,view,eventListener)







    this.dataModelObj=req;


    this.dataModelObj.setDasObject(this);

    this.setDisplayIcon()
    this.dataUuid=req.getUuid;
    this.parent=parent;
    if isa(parent,'slreq.das.Requirement')
        this.RequirementSet=parent.RequirementSet;
    elseif isa(parent,'slreq.das.RequirementSet')
        this.RequirementSet=parent;
    end
    this.view=view;
    this.eventListener=eventListener;
    this.children=slreq.das.Requirement.empty();
end
