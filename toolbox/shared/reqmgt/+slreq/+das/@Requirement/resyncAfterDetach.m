function resyncAfterDetach(this)











    dataReq=this.dataModelObj;
    recAddDasObjctsIfNeeded(this,dataReq);

    function recAddDasObjctsIfNeeded(dasReqParent,dataReq)

        dasReq=dataReq.getDasObject();
        if isempty(dasReq)

            dasReq=slreq.das.Requirement();
            dasReq.postConstructorProcess(dataReq,dasReqParent,dasReqParent.view,dasReqParent.eventListener);
            dasReqParent.addChildObject(dasReq);
        end

        dataChildren=dataReq.children;
        for n=1:length(dataChildren)
            recAddDasObjctsIfNeeded(dasReq,dataChildren(n));
        end
    end
end
