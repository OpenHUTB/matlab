function moveBlockTypes(dstModelcovId,srcModelcovId)




    srcBlockTypes=cv('get',srcModelcovId,'.blockTypes');
    dstBlockTypes=cv('get',dstModelcovId,'.blockTypes');

    if isempty(dstBlockTypes)
        cv('set',dstModelcovId,'.blockTypes',srcBlockTypes)
        return;
    elseif isempty(srcBlockTypes)
        return;
    end
    srcBlockTypeName=cv('get',srcBlockTypes,'.type');
    dstBlockTypeName=cv('get',dstBlockTypes,'.type');
    [~,dI]=setdiff(srcBlockTypeName,dstBlockTypeName,'row');
    if~isempty(dI)
        cv('set',dstModelcovId,'.blockTypes',[dstBlockTypes,srcBlockTypes(dI)]);
    end



