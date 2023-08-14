function[isProxy,grpName,domain,customId]=resolveProxyToExtReq(req)




    isProxy=false;
    grpName='';
    domain=req.reqsys;
    customId=req.id;

    reqSet=slreq.data.ReqData.getInstance.getReqSet(req.doc);
    if~isempty(reqSet)
        reqItem=reqSet.getRequirementById(req.id);
        if~isempty(reqItem)&&reqItem.external
            isProxy=true;
            domain=reqItem.domain;
            grpName=reqItem.artifactUri;
            customId=reqItem.customId;
        end
    end
end
