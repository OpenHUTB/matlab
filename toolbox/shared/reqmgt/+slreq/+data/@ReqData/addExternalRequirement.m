function reqObj=addExternalRequirement(this,parent,reqInfo)






    if(~isa(parent,'slreq.data.RequirementSet')&&~isa(parent,'slreq.data.Requirement'))
        error('Invalid argument of type %s',class(parent)');
    end

    if isempty(reqInfo.domain)||isempty(reqInfo.artifactUri)
        error('ReqData.addExternalRequirement() requires non-empty .domain and .artifactUri field values');
    end

    if isa(parent,'slreq.data.RequirementSet')
        parentReq=[];
        mfReqSet=this.getModelObj(parent);
    else
        parentReq=this.getModelObj(parent);
        mfReqSet=parentReq.requirementSet;
    end

    if isempty(mfReqSet)
        error('ReqData.addExternalRequirement(): no destination RequirementSet');
    end



    group=[];
    if isfield(reqInfo,'group')
        group=reqInfo.group;
    end

    if isempty(group)
        group=this.getGroup(reqInfo.artifactUri,reqInfo.domain,mfReqSet);
    else

        reqInfo.artifactUri=group.artifactUri;
    end


    if~isfield(reqInfo,'id')
        reqInfo.id='';
    end
    if~isfield(reqInfo,'summary')
        reqInfo.summary='';
    end
    if~isfield(reqInfo,'description')
        reqInfo.description='';
    end


    mfReq=this.addExternalReq(group,reqInfo);

    if isempty(mfReq.typeName)
        mfReq.typeName=mfReqSet.defaultTypeName;
    end

    this.resolveRequirementType(mfReq);



    this.insertReqAndNotify(mfReqSet,parentReq,mfReq);


    reqObj=this.wrap(mfReq);



    mfReqSet.dirty=true;



end

