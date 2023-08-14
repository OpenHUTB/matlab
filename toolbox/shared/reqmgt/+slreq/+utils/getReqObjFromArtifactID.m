function reqObj=getReqObjFromArtifactID(artifactUri,artifactid)
    reqSet=slreq.data.ReqData.getInstance.getReqSet(artifactUri);
    reqObj=[];
    if~isempty(reqSet)
        reqObj=reqSet.getRequirementById(artifactid);
    end
end