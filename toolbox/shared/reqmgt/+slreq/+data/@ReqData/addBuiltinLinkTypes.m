function addBuiltinLinkTypes(this)








    unsetType=addLinkType(this,'Unset','','',slreq.datamodel.LinkType.empty);
    linkTypes=enumeration(slreq.custom.LinkType.DefaultValue);
    for n=1:length(linkTypes)
        linkType=linkTypes(n);
        addLinkType(this,linkType.getTypeName,linkType.forwardName,linkType.backwardName,unsetType);
    end
end

function mfLinkType=addLinkType(this,typeName,forwardName,backwardName,superType)
    mfLinkType=slreq.datamodel.LinkType(this.model);
    mfLinkType.typeName=typeName;
    mfLinkType.forwardName=forwardName;
    mfLinkType.backwardName=backwardName;
    mfLinkType.isBuiltin=true;
    mfLinkType.superType=superType;
    this.repository.linkTypes.add(mfLinkType);
end
