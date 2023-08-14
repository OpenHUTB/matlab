
function saveReqOrLinkSets(cbinfo)
    appmgr=slreq.app.MainManager.getInstance();
    currentObj=[];

    if appmgr.requirementsEditor.isReqViewActive
        appmgr.callbackHandler.saveAllReqSets(currentObj,false);
    else
        appmgr.callbackHandler.saveAllLinkSets(currentObj,false);
    end
end