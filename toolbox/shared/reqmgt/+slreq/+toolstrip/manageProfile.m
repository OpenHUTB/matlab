function manageProfile(cbinfo)

    slreq.toolstrip.activateEditor(cbinfo);
    appmgr=slreq.app.MainManager.getInstance();
    selectedObj=appmgr.getCurrentObject();

    dasLinkReqSet=[];
    if isa(selectedObj,'slreq.das.Requirement')
        dasLinkReqSet=selectedObj.RequirementSet;
    elseif isa(selectedObj,'slreq.das.RequirementSet')
        dasLinkReqSet=selectedObj;
    elseif isa(selectedObj,'slreq.das.LinkSet')
        dasLinkReqSet=selectedObj;
    elseif isa(selectedObj,'slreq.das.Link')
        dasLinkReqSet=selectedObj.parent;
    end

    if~isempty(dasLinkReqSet)
        dlg=slreq.gui.ManageProfileDialog(dasLinkReqSet);
        dialog=DAStudio.Dialog(dlg);
        dialog.Position=[200,200,600,300];
        dialog.show();
    end
end