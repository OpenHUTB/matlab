function needIndexing=setRootVariantFromCvdata(cvd)



    try
        rootId=cvd.rootID;
        indexedForVariantStates=cvi.RootVariant.getRootVariantStates(rootId);
        dataVariantStates=cvd.getRootVariantStates;
        needIndexing=false;
        if isempty(indexedForVariantStates)&&isempty(dataVariantStates)
            return;
        end
        if cvi.RootVariant.compareVariantStates(indexedForVariantStates,dataVariantStates)
            return;
        end


        needIndexing=cvi.RootVariant.resetRootVariants(cv('get',rootId,'.modelcov'));


        variants=cvi.RootVariant.getRootVariants(rootId);
        changedVariants=[];

        for idx=1:numel(dataVariantStates)
            cvs=dataVariantStates(idx);
            vId=cv('find',variants,'.path',cvs.path,'.variantPath',cvs.variantPath);
            changedVariants=[changedVariants,cvi.RootVariant.setRootVariantState(rootId,vId,cvs.state)];
        end
        if~isempty(changedVariants)
            roots=cv('RootsIn',cv('get',rootId,'.modelcov'));
            for idx=1:numel(roots)
                cv('RootUpdateChecksum',roots(idx));
            end
            needIndexing=true;
        end
    catch MEx
        rethrow(MEx);
    end
end

