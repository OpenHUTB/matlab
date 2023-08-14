function modifyFunctionOrder(functionInfoTab,modifier)



    fcns=functionInfoTab.getCurrentSelection();
    if~isempty(fcns)
        [~,sortedIdxs]=sort(cellfun(@(f)f.get().executionOrder,fcns));
        txn=mf.zero.getModel(fcns{1}.get()).beginTransaction();
        for idx=1:numel(sortedIdxs)
            fcn=fcns{sortedIdxs(idx)};
            fcn.get().setOrder(fcn.get().executionOrder+modifier);

        end
        fcn(1).syncBlockPriorities();
        txn.commit();
    end
end
