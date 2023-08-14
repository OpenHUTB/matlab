function addSiblingReq(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    appmgr=slreq.app.MainManager.getInstance();
    current=appmgr.getCurrentViewSelections();
    if isa(current,'slreq.das.Requirement')
        slreq.das.Requirement.onAddRequirementAfter();
    elseif isa(current,'slreq.das.RequirementSet')
        slreq.das.RequirementSet.onAddRequirement();
    end
end