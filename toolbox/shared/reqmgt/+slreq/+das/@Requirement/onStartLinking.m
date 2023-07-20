function onStartLinking()






    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    if isa(currentReq,'slreq.das.Requirement')
        appmgr=slreq.app.MainManager.getInstance();
        appmgr.linkTargetReqObject=currentReq;
    end
end
