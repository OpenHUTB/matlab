function refObj=getImportedReference(reqInfo)
    refObj=[];
    if~strcmp(reqInfo.reqsys,'linktype_rmi_slreq')
        return;
    end
    if isempty(reqInfo.doc)||isempty(reqInfo.id)
        return;
    end
    dataReqSet=slreq.data.ReqData.getInstance.getReqSet(reqInfo.doc);
    if isempty(dataReqSet)
        return;
    end
    dataReq=dataReqSet.getRequirementById(reqInfo.id);
    if~isempty(dataReq)&&dataReq.external
        refObj=dataReq;
    end
end

