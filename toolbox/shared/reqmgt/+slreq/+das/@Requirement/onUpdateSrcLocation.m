function onUpdateSrcLocation()







    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    docRefNode=currentReq.dataModelObj;

    parentReqSet=docRefNode.getReqSet();
    parentReqSet.updateSrcArtifactUri(docRefNode,'');


end
