function unresolveCustomLinkTypes(this)






    linkTypes=this.repository.linkTypes.toArray;
    unsetType=this.getLinkType('Unset');

    for n=1:length(linkTypes)
        linkType=linkTypes(n);
        if~linkType.isBuiltin&&linkType~=unsetType

            linkType.superType=unsetType;
            linkType.forwardName=getString(message('Slvnv:slreq:UnresolvedType',linkType.typeName));
            linkType.backwardName=getString(message('Slvnv:slreq:UnresolvedType',linkType.typeName));
            linkType.description='';
        end
    end
end