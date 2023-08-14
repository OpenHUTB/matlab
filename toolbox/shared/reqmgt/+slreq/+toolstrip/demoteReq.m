function demoteReq(cbinfo)
    appmgr=slreq.app.MainManager.getInstance();
    currentObj=appmgr.getCurrentObject();
    appmgr.callbackHandler.demote(currentObj);
end