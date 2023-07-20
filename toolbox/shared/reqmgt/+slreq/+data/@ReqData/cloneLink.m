function dataLink=cloneLink(this,dataSourceItem,dataOrigLink)








    mfSourceItem=this.getModelObj(dataSourceItem);
    mfLinkSet=mfSourceItem.artifact;
    mfOrigLink=this.getModelObj(dataOrigLink);


    mfLink=slreq.datamodel.Link(this.model);
    mfLink.source=mfSourceItem;
    mfLink.description=mfOrigLink.description;
    mfLink.revision=mfOrigLink.revision;
    mfLink.linkedVersion=mfOrigLink.linkedVersion;
    mfLink.createdOn=mfOrigLink.createdOn;
    mfLink.createdBy=mfOrigLink.createdBy;
    mfLink.modifiedOn=mfOrigLink.modifiedOn;
    mfLink.modifiedBy=mfOrigLink.modifiedBy;
    mfLink.linktype=mfOrigLink.linktype;

    origRef=mfOrigLink.dest;
    ref=slreq.datamodel.Reference(this.model);
    ref.artifactUri=origRef.artifactUri;
    ref.artifactId=origRef.artifactId;
    ref.requirement=origRef.requirement;
    ref.domain=origRef.domain;
    ref.reqSetUri=origRef.reqSetUri;
    ref.linkedVersion=origRef.linkedVersion;
    ref.linkedTime=origRef.linkedTime;
    ref.summary=origRef.summary;
    ref.url=origRef.url;
    mfLink.dest=ref;
    mfLink.setProperty('isSurrogateLink',mfOrigLink.getProperty('isSurrogateLink'));
    this.setKeywords(mfLink,dataOrigLink.keywords);
    mfLink.typeName=mfOrigLink.typeName;

    mfLinkSet.addLink(mfLink);




    dataLink=this.wrap(mfLink);
    this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('Link Added',dataLink));
end

