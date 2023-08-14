function destroyFunctionAndRootInportBlock(aFunction)





    rootArch=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(...
    mf.zero.getModel(aFunction)).getRootArchitecture();

    assert(swarch.utils.isInlineSoftwareComponent(aFunction.calledFunctionParent)||...
    strcmp(get_param(rootArch.getName(),'AutosarExportToRateBasedArch'),'on'),...
    'Only functions in inline software components can be explicitly destroyed');

    inpBlock=swarch.utils.getFcnCallInport(aFunction);
    if~isempty(inpBlock)

        delete_block(swarch.utils.getFcnCallInport(aFunction));
    end


    txn=mf.zero.getModel(aFunction).beginTransaction();
    aFunction.calledFunction.destroy();
    aFunction.destroy();
    txn.commit();
end


