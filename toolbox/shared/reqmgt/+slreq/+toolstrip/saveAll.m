
function saveAll(cbinfo)


    appmgr=slreq.app.MainManager.getInstance();


    currentObj=[];
    appmgr.callbackHandler.saveAllReqLinkSet(currentObj);
end
