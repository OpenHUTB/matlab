classdef RootVariant
    methods(Static)

        checkVariantSubsystems(rootId)
        [variants,topRootId]=getRootVariants(rootId)
        changedVariants=setRootVariantState(rootId,variantId,state)
        variantId=addRootVariant(rootId,blockPath,variantPath)
        variantStates=getRootVariantStates(rootId)
        needUpdateHandles=compareRootVariants(newRootId,oldRootId)
        res=compareVariantStates(oldState,newState)
        refreshModelcovIds(slsfId,modelcovId)

        needIndexing=setRootVariantFromCvdata(cvd)
        res=resetRootVariants(modelcovId)

        function vId=findRootVariant(rootId,path)
            variants=cvi.RootVariant.getRootVariants(rootId);
            vId=cv('find',variants,'.path',path);
        end
    end
end