function reqObj=addRequirement(this,parent,reqInfo)






    slreq.utils.assertValid(parent);

    if(~isa(parent,'slreq.data.RequirementSet')&&~isa(parent,'slreq.data.Requirement'))
        error('Invalid argument: expected slreq.data.RequirementSet or slreq.data.Requirement');
    end

    reqObj=[];

    if isa(parent,'slreq.data.RequirementSet')
        parentReq=[];
        mfReqSet=this.getModelObj(parent);
    elseif parent.isJustification
        error(message('Slvnv:slreq:FailedToAddInternalInJustification'));
    else
        parentReq=this.getModelObj(parent);
        mfReqSet=parentReq.requirementSet;
    end

    if isempty(mfReqSet)
        return;
    end

    if nargin==2||isempty(reqInfo)
        reqInfo.id='';
        reqInfo.summary='';
        reqInfo.description='';

    elseif~isstruct(reqInfo)
        error('Invalid argument of type %s in a call to addRequirement()',class(reqInfo));
    end


    mfReq=this.createRequirement(reqInfo);
    this.setCustomAttributesForNewReq(mfReq,mfReqSet,reqInfo);


    mfReq.revision=mfReqSet.revision;
    mfReqSet.addItem(mfReq);

    if isempty(mfReq.typeName)
        mfReq.typeName=mfReqSet.defaultTypeName;
    end
    this.resolveRequirementType(mfReq);



    this.insertReqAndNotify(mfReqSet,parentReq,mfReq);


    reqObj=this.wrap(mfReq);




    dataReqSet=this.wrap(mfReqSet);

    if~mfReqSet.dirty

        dataReqSet.setDirty(true);
    end

    reqObj.setDirty(true);



    mfReq.createdOn=mfReq.modifiedOn;
end
