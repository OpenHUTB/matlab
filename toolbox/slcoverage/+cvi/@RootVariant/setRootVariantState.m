function changedVariants=setRootVariantState(rootId,variantId,state)



    try
        changedVariants=[];

        if state&&cv('get',variantId,'.isVariantSubsys')

            relatedVariants=getRelatedVariants(rootId,variantId);
            for idx=1:numel(relatedVariants)
                if setState(rootId,relatedVariants(idx),0)
                    changedVariants=[changedVariants,relatedVariants(idx)];%#ok<AGROW>
                end
            end
        end
        if setState(rootId,variantId,state)
            changedVariants=[changedVariants,variantId];
        end
    catch MEx
        rethrow(MEx);
    end
end


function change=setState(rootId,variantId,state)
    change=false;
    if cv('get',variantId,'.state')==state
        return;
    end
    turnOff=0;
    if state==0
        turnOff=1;
    end

    cv('RootSetVariant',rootId,variantId,state);

    scopeId=cv('get',variantId,'.scope');
    parentId=cv('get',variantId,'.parent');
    allIds=[scopeId,cv('DecendentsOf',scopeId)];
    if cv('get',variantId,'.isVariantSubsys')
        allIds=[parentId,allIds];
    end
    cv('set',allIds,'.isDormant',turnOff);

    change=true;

end

function allVariants=getRelatedVariants(rootId,variantId)
    variantIds=cvi.RootVariant.getRootVariants(rootId);
    variantSubsysPath=cv('get',variantId,'.variantPath');
    allVariants=cv('find',variantIds,'.variantPath',variantSubsysPath);
    allVariants(allVariants==variantId)=[];
end