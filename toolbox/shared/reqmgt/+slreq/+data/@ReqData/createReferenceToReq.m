function ref=createReferenceToReq(this,mfReq,refPath)






    ref=slreq.datamodel.Reference(this.model);
    ref.domain='linktype_rmi_slreq';
    reqSetName=mfReq.requirementSet.name;

    isEmbeededReq=~isempty(mfReq.requirementSet.parent);
    if isEmbeededReq
        [fPath,~,~]=fileparts(mfReq.requirementSet.filepath);
        artifactUri=fullfile(fPath,mfReq.requirementSet.parent);
        longId=[reqSetName,'.slreqx~',num2str(mfReq.sid)];
        ref.reqSetUri=sprintf('%s:%s',mfReq.requirementSet.parent,longId);
        ref.artifactUri=slreq.uri.getPreferredPath(artifactUri,refPath);
        ref.artifactId=longId;
    else
        reqSID=mfReq.sid;
        ref.reqSetUri=sprintf('%s:%d',reqSetName,reqSID);

        ref.artifactUri=slreq.uri.getPreferredPath(mfReq.requirementSet.filepath,refPath);
        ref.artifactId=sprintf('%d',reqSID);
    end

    ref.requirement=mfReq;
    this.updateLinkedTimeAndVersion(ref,mfReq,true);
end
