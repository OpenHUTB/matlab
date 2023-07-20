function onAddChildRequirement()






    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    if isa(currentReq,'slreq.das.Requirement')
        appmgr=slreq.app.MainManager.getInstance;
        appmgr.callbackHandler.addChildRequirement(currentReq);
    end
end
