function res=resetRootVariants(modelcovId)





    try
        res=false;

        allRoots=cv('RootsIn',modelcovId);

        for idx=1:numel(allRoots)
            crId=allRoots(idx);
            variants=cvi.RootVariant.getRootVariants(crId);
            changedVariants=[];
            for idx1=1:numel(variants)
                variantId=variants(idx1);
                if cv('get',variantId,'.isVariantSubsys')~=1
                    changedVariants=[changedVariants,cvi.RootVariant.setRootVariantState(crId,variants(idx1),1)];
                end
            end
            if~isempty(changedVariants)
                cv('RootUpdateChecksum',crId);
                res=true;
            end
        end

    catch MEx
        rethrow(MEx);
    end
end
