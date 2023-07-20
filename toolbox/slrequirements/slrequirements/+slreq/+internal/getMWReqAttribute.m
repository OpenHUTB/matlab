function value=getMWReqAttribute(reqInfo,attributeName)







    if~isstruct(reqInfo)
        error(message('Slvnv:rmipref:InvalidArgument',class(reqInfo)));
    end

    if isfield(reqInfo,'reqsys')&&strcmp(reqInfo.reqsys,'linktype_rmi_slreq')

        reqSetName=reqInfo.doc;

    elseif isfield(reqInfo,'domain')&&strcmp(reqInfo.domain,'linktype_rmi_slreq')

        reqSetName=reqInfo.artifact;

    else
        error(message('Slvnv:rmipref:InvalidArgument',class(reqInfo)));
    end

    dataReq=getDataReq(reqSetName,reqInfo.id);
    if isempty(dataReq)
        rmiut.warnNoBacktrace('Slvnv:reqmgt:NotFoundIn',reqInfo.id,reqSetName);
        value='';
    else
        value=dataReq.getAttribute(attributeName);
    end
end

function dataReq=getDataReq(reqSetName,reqId)
    dataReq=[];
    reqData=slreq.data.ReqData.getInstance();
    dataReqSet=reqData.getReqSet(reqSetName);
    if~isempty(dataReqSet)
        dataReq=dataReqSet.getRequirementById(reqId);
    end
end