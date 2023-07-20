function onDeleteRequirement()






    appmgr=slreq.app.MainManager.getInstance;
    currentReq=appmgr.getCurrentViewSelections;
    if isa(currentReq,'slreq.das.Requirement')
        appmgr.callbackHandler.delReqLink(currentReq);
    end
end
