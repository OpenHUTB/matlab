function linktypes=getAllLinkTypes(this)







    linktypes=this.repository.linkTypes.toArray;

    UnsetType=this.repository.linkTypes{'Unset'};
    linktypes(linktypes==UnsetType)=[];
end
