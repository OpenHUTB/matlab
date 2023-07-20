function onMoveDownRequirement()


    appmgr=slreq.app.MainManager.getInstance();
    currentReq=appmgr.getCurrentViewSelections();

    if isa(currentReq,'slreq.das.Requirement')
        srcDataReq=currentReq.dataModelObj;
        srcDataReq.moveDown();
    end
end
