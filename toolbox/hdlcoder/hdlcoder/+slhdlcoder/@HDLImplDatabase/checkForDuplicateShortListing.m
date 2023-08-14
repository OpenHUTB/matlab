function dupName=checkForDuplicateShortListing(this,curImpls,description)







    if~iscell(curImpls)
        curImpls={curImpls};
    end

    dupName='';
    for ii=1:length(curImpls)
        curImpl=curImpls{ii};
        value=this.getDescription(curImpl);
        if~isempty(value)&&strcmp(value.ShortListing,description.ShortListing)
            dupName=curImpl;
            break;
        end
    end
