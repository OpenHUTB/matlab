function setSelectedObject(this,dasObjs)









    this.currentObject=dasObjs;

    for n=1:length(dasObjs)
        if isa(dasObjs(n),'slreq.das.Requirement')...
            &&dasObjs(n).dataModelObj.isImportRootItem()

            dataReq=dasObjs(n).dataModelObj;
            updateDetectionMgr=slreq.dataexchange.UpdateDetectionManager.getInstance();
            updateDetectionMgr.detectByTimestamp(dataReq);
        end
    end
end
