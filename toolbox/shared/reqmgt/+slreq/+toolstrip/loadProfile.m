function loadProfile(cbinfo)

    slreq.toolstrip.activateEditor(cbinfo);

    appmgr=slreq.app.MainManager.getInstance();
    selectedObj=appmgr.getCurrentObject();
    dasLinkReqSet=[];
    if isa(selectedObj,'slreq.das.Requirement')
        dasLinkReqSet=selectedObj.RequirementSet;
    elseif isa(selectedObj,'slreq.das.RequirementSet')
        dasLinkReqSet=selectedObj;
    elseif isa(selectedObj,'slreq.das.Link')
        dasLinkReqSet=selectedObj.parent;
    elseif isa(selectedObj,'slreq.das.LinkSet')
        dasLinkReqSet=selectedObj;
    end

    if~isempty(dasLinkReqSet)
        if isempty(cbinfo.EventData)||strcmp(cbinfo.EventData,'')

            profilePath=appmgr.callbackHandler.pickProfile(cbinfo);
        else
            profilePath=cbinfo.EventData;
        end

        if~isempty(profilePath)
            dasLinkReqSet.dataModelObj.importProfile(profilePath);

            mgr=slreq.app.MainManager.getInstance();
            mgr.refreshUI(dasLinkReqSet);
        end
    end
end