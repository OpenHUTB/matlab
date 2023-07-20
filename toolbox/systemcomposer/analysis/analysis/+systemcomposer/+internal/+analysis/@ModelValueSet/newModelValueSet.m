function modelValueSet=newModelValueSet(instanceModel)


    mfmodel=mf.zero.getModel(instanceModel);
    txn=mfmodel.beginTransaction;
    modelValueSet=systemcomposer.internal.analysis.ModelValueSet(mfmodel);
    modelValueSet.instanceModel=instanceModel;
    usages=instanceModel.p_PropertySets.toArray;
    if~isempty(usages)&&~isempty(instanceModel.root)
        modelValueSet.addInstanceValueSet(instanceModel.root);
    end
    txn.commit;
end

