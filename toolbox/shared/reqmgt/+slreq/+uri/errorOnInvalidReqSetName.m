




function errorOnInvalidReqSetName(reqSetPathOrName)


    slreq.uri.errorOnReservedReqSetName(reqSetPathOrName);

    reqData=slreq.data.ReqData.getInstance;

    if~isempty(reqData.getReqSet(reqSetPathOrName))
        error(message('Slvnv:slreq:RequirementSetAlreadyLoaded',reqSetPathOrName));
    end
end
