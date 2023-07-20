function justificationObj=addJustification(this,dataBaseObj,addType,reqInfo)









    mfBase=this.getModelObj(dataBaseObj);

    if strcmp(addType,'child')
        modelParent=mfBase;
    elseif strcmp(addType,'after')
        modelParent=mfBase.parent;
    end

    if isa(mfBase,'slreq.datamodel.RequirementSet')
        mfReqSet=mfBase;
    else
        mfReqSet=mfBase.requirementSet;
    end

    if nargin==2||isempty(reqInfo)
        reqInfo.id='';
        reqInfo.summary='';
        reqInfo.description='';
    end


    mfJustification=this.createJustification(reqInfo);
    this.setCustomAttributesForNewReq(mfJustification,mfReqSet,reqInfo);

    mfJustificationParent=[];
    if isa(modelParent,'slreq.datamodel.Justification')

        mfJustificationParent=modelParent;
    else


        if mfReqSet.rootItems.Size>0


            lastRootItem=mfReqSet.rootItems.at(mfReqSet.rootItems.Size);
            if isa(lastRootItem,'slreq.datamodel.Justification')

                mfJustificationParent=lastRootItem;
            end
        end
    end

    if isempty(mfJustificationParent)


        parenqReqInfo.summary=getString(message('Slvnv:slreq:Justifications'));
        parenqReqInfo.id='';
        parenqReqInfo.description='';
        mfJustificationParent=this.createJustification(parenqReqInfo);


        mfReqSet.addRootItem(mfJustificationParent);
        mfJustificationParent.requirementSet=mfReqSet;
        this.wrap(mfJustificationParent);
        mfJustificationParent.createdOn=mfJustificationParent.modifiedOn;
    end

    mfReqSet.addItem(mfJustification);
    mfJustificationParent.children.add(mfJustification);

    if strcmp(addType,'after')

        this.moveRequirement(mfJustification,'after',mfBase);
    end


    justificationObj=this.wrap(mfJustification);

    if strcmp(addType,'child')
        this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Justification Added',justificationObj));
    elseif strcmp(addType,'after')
        this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement AddedAfter',justificationObj));
    end

    if~mfReqSet.dirty
        dataReqSet=this.wrap(mfReqSet);

        dataReqSet.setDirty(true);
    end



    mfJustification.createdOn=mfJustification.modifiedOn;
end
