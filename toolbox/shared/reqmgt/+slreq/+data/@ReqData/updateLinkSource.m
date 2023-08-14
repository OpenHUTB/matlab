function updateLinkSource(this,dataLink,newSrcStruct)






    changedInfo.propName='source';
    changedInfo.oldValue=dataLink.source;

    if~rmiut.isCompletePath(newSrcStruct.artifact)

        newSrcStruct.artifact=rmiut.absolute_path(newSrcStruct.artifact);
    end



    srcDataLinkSet=dataLink.getLinkSet();
    srcMfLinkSet=this.getModelObj(srcDataLinkSet);
    domain=srcDataLinkSet.domain;
    destArtifact=newSrcStruct.artifact;
    if~strcmp(srcDataLinkSet.artifact,destArtifact)


        if~strcmp(domain,newSrcStruct.domain)
            error(message('Slvnv:slreq:LinkDomainMismatch',srcDataLinkSet.domain));
        end

        if~isfield(newSrcStruct,'srcRaname')||~newSrcStruct.srcRaname
            error(message('Slvnv:slreq:LinkDomainMismatch',srcDataLinkSet.artifact));
        end

        destMfLinkSet=this.findLinkSet(destArtifact,domain);
        if isempty(destMfLinkSet)
            destMfLinkSet=this.addLinkSet(destArtifact,domain);
        end
        isOtherSet=true;
    else
        destMfLinkSet=srcMfLinkSet;
        isOtherSet=false;
    end



    if strcmp(domain,'linktype_rmi_slreq')&&isfield(newSrcStruct,'sid')

        newSrcStruct.id=num2str(newSrcStruct.sid);
    end

    mfLink=this.getModelObj(dataLink);
    mfOldSrcItem=mfLink.source;
    mfNewSrcItem=this.ensureLinkableItem(destMfLinkSet,newSrcStruct);

    if isequal(mfNewSrcItem,mfOldSrcItem)

        return;
    end

    if strcmp(newSrcStruct.domain,'linktype_rmi_slreq')
        mfReqSet=this.findRequirementSet(newSrcStruct.artifact);
        if~isempty(mfReqSet)
            mfReq=this.findRequirement(mfReqSet,newSrcStruct.id);
            if~isempty(mfReq)

                this.updateLinkedTimeAndVersion(mfLink,mfReq,true);
            end
        end
    end


    dataLink.setDirty(true);

    if isOtherSet

        this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('BeforeDeleteLink',dataLink));
        this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Link Deleted',dataLink));
    end

    this.wrap(mfNewSrcItem);
    mfOldSrcItem.outgoingLinks.remove(mfLink);
    mfLink.source=mfNewSrcItem;


    if isOtherSet
        srcMfLinkSet.links.remove(mfLink);
        destMfLinkSet.addLink(mfLink);
        destDataLinkSet=this.wrap(destMfLinkSet);
        destDataLinkSet.setDirty(true);
        this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Link Added',dataLink));
    else
        changedInfo.newValue=dataLink.source;
        this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Set Prop Update',dataLink,changedInfo));
    end
end
