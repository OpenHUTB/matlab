function onOpenLinkEditor()








    currentReq=slreq.app.MainManager.getCurrentViewSelections();
    if isa(currentReq,'slreq.das.Requirement')
        [~,outLinks]=currentReq.dataModelObj.getLinks();
        destReqInfo=slreq.utils.linkToStruct(outLinks);
        ReqMgr.rmidlg_mgr('slreq',currentReq.dataModelObj,destReqInfo,-1);
    end
end
