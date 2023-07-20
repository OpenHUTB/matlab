function replaceSourceId(this,artifactName,origId,newId)






    linkset=this.findLinkSet(artifactName);
    if isempty(linkset)
        return;
    end

    origItem=this.findLinkableItem(linkset,struct('id',origId));
    staleItem=this.findLinkableItem(linkset,struct('id',newId));
    if~isempty(staleItem)
        artifact=staleItem.artifact;
        artifact.items.remove(staleItem);
    end






    origItem.id=newId;

end

