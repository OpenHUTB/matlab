function onAddRequirementAfter()






    currentReq=slreq.app.MainManager.getCurrentViewSelections;
    if isa(currentReq,'slreq.das.Requirement')
        appmgr=slreq.app.MainManager.getInstance;
        appmgr.callbackHandler.addRequirementAfter(currentReq);
    end
end
