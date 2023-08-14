




function needUpdateHandles=compareRootVariants(newRootId,oldRootId)

    try


        needUpdateHandles=true;
        oldVariants=cvi.RootVariant.getRootVariants(oldRootId);
        newVariants=cvi.RootVariant.getRootVariants(newRootId);
        hasOldVariants=~isempty(oldVariants);
        hasNewVariants=~isempty(newVariants);

        if~hasOldVariants&&~hasNewVariants
            return;
        end
        oldVariantState=cvi.RootVariant.getRootVariantStates(oldRootId);
        newVariantState=cvi.RootVariant.getRootVariantStates(newRootId);
        if cvi.RootVariant.compareVariantStates(oldVariantState,newVariantState)
            return;
        end

        changedVariants=false;

        for idx=1:numel(newVariants)
            newVariantId=newVariants(idx);
            newVariantSate=cv('get',newVariantId,'.state');
            foundId=findVariant(oldVariants,newVariantId);
            if isempty(foundId)
                variantId=copyVariant(oldRootId,oldVariants,newVariantId);
                changedVariants=changedVariants||true;
            else
                variantId=foundId;
            end
            tcv=cvi.RootVariant.setRootVariantState(oldRootId,variantId,newVariantSate);
            changedVariants=changedVariants||~isempty(tcv);


            modelcovId=cv('get',oldRootId,'.modelcov');
            cvi.RootVariant.refreshModelcovIds(cv('get',variantId,'.scope'),modelcovId);

        end

        if changedVariants
            roots=cv('RootsIn',cv('get',oldRootId,'.modelcov'));
            for idx=1:numel(roots)
                cv('RootUpdateChecksum',roots(idx));
            end
            needUpdateHandles=false;
        end
        res=compareCheck(oldRootId,newRootId);
    catch MEx
        rethrow(MEx);
    end
end


function res=compareCheck(obj1,obj2)
    checksum1=cv('get',obj1,'.checksum');
    checksum2=cv('get',obj2,'.checksum');
    res=isequal(checksum1,checksum2);
end

function variantId=findVariant(oldVariants,newVariantId)

    path=cv('get',newVariantId,'.path');
    variantId=cv('find',oldVariants,'.path',path);
end

function variantId=copyVariant(oldRootId,oldVariants,newVariantId)
    isVariantSubsystem=cv('get',newVariantId,'.isVariantSubsys');


    if isVariantSubsystem
        newVariantPath=cv('get',newVariantId,'.variantPath');

        oldVariantIds=cv('find',oldVariants,'.variantPath',newVariantPath);

        oldVariantId=oldVariantIds(1);

        oldState=cv('get',oldVariantId,'.state');
        cvi.RootVariant.setRootVariantState(oldRootId,oldVariantId,0);


        variantId=cv('new','rootvariant');
        cv('set',variantId,'.scope',cv('get',newVariantId,'.scope'));
        cv('set',variantId,'.path',cv('get',newVariantId,'.path'));
        cv('set',variantId,'.variantPath',cv('get',newVariantId,'.variantPath'));

        cv('set',variantId,'.parent',cv('get',oldVariantId,'.parent'));
        cv('set',variantId,'.beforeChild',cv('get',oldVariantId,'.beforeChild'));
        cv('set',variantId,'.isVariantSubsys',1);
        cv('set',variantId,'.state',cv('get',oldVariantId,'.state'));


        cvi.RootVariant.setRootVariantState(oldRootId,oldVariantId,oldState);

        [oldVariants,oldTopRootId]=cvi.RootVariant.getRootVariants(oldRootId);
        oldVariants(end+1)=variantId;
        cv('set',oldTopRootId,'.variants',oldVariants);
    else
        slsfId=cv('get',newVariantId,'.scope');


        handle=cv('get',slsfId,'.handle');
        variantPath=cv('get',newVariantId,'.variantPath');
        variantId=cvi.RootVariant.addRootVariant(oldRootId,handle,variantPath);
    end
end

