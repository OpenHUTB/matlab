function promoteReq(cbinfo)
    appmgr=slreq.app.MainManager.getInstance();
    currentObj=appmgr.getCurrentObject();
    appmgr.callbackHandler.promote(currentObj);
end