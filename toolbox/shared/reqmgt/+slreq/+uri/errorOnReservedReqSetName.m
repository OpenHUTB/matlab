function errorOnReservedReqSetName(reqSetPathOrName)







    reqData=slreq.data.ReqData.getInstance;
    [~,shortName]=fileparts(reqSetPathOrName);
    if reqData.isReservedReqSetName(reqSetPathOrName)
        error(message('Slvnv:slreq:RequirementSetNameReserved',shortName));
    end
end
