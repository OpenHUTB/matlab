function dataReq=addRequirementAfter(this,dataReqBase)






    slreq.utils.assertValid(dataReqBase);

    if~isa(dataReqBase,'slreq.data.Requirement')
        error('Invalid argument of type %s',class(dataReqBase)');
    end

    base=dataReqBase.getModelObj();
    destReqSet=base.requirementSet;

    assert(~isempty(destReqSet),'addRequirementAfter is called for a dangling requirement')



    reqInfo=struct('id','','summary','','description','');


    mfReq=this.createRequirement(reqInfo);
    mfReq.revision=destReqSet.revision;

    destReqSet.addItem(mfReq);

    if~isempty(base.parent)
        mfReq.parent=base.parent;
    else

        destReqSet.rootItems.add(mfReq);
    end

    if isa(base,'slreq.datamodel.Justification')&&isa(mfReq,'slreq.datamodel.MwRequirement')
        success=this.moveRequirement(mfReq,'before',base);
    else
        success=this.moveRequirement(mfReq,'after',base);
    end
    if~success

        dataReq=[];
        return;
    end
    mfReq.typeName=destReqSet.defaultTypeName;
    this.resolveRequirementType(mfReq);


    dataReq=this.wrap(mfReq);



    dataReqSet=this.wrap(destReqSet);


    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement AddedAfter',dataReq));

    if~destReqSet.dirty

        dataReqSet.setDirty(true);
    end

    dataReq.setDirty(true);



    mfReq.createdOn=mfReq.modifiedOn;
end
