function onSelectionJustificationLinkingForVerification()








    appmgr=slreq.app.MainManager.getInstance();
    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    dataLink=currentReq.addLink(appmgr.linkTargetReqObject);
    dataLink.type='Verify';
    appmgr.update;
end
