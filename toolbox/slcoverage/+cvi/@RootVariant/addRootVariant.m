function variantId=addRootVariant(rootId,blockPath,variantPath)




    if nargin<3
        variantPath='';
    end
    variantId=[];
    if isempty(blockPath)
        return;
    end
    variants=cvi.RootVariant.getRootVariants(rootId);
    variantId=cv('find',variants,'.path',blockPath);
    if~isempty(variantId)
        return;
    end

    blockCvId=cvprivate('find_block_cv_id',rootId,blockPath);
    if ischar(blockCvId)||isempty(blockCvId)
        return;
    end


    variantId=cv('new','rootvariant');
    cv('set',variantId,'.scope',blockCvId);
    path=getfullname(cv('get',blockCvId,'.handle'));
    cv('set',variantId,'.path',path);
    if~isempty(variantPath)
        cv('set',variantId,'.variantPath',variantPath);
        cv('set',variantId,'.isVariantSubsys',1);
    end


    cv('set',variantId,'.state',1);


    [oldVariants,topRootId]=cvi.RootVariant.getRootVariants(rootId);

    if~isempty(oldVariants)
        newVariants=[oldVariants,variantId];
    else
        newVariants=variantId;
    end


    cv('set',topRootId,'.variants',newVariants);

end


