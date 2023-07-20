function swapSourceIds(this,artifactName,firstId,secondId)






    linkset=this.findLinkSet(artifactName);
    if isempty(linkset)
        return;
    end

    firstItem=this.findLinkableItem(linkset,struct('id',firstId));
    secondItem=this.findLinkableItem(linkset,struct('id',secondId));




    firstItem.id=['~',firstItem.id];
    secondItem.id=['~',secondItem.id];

    firstItem.id=secondId;
    secondItem.id=firstId;
end
