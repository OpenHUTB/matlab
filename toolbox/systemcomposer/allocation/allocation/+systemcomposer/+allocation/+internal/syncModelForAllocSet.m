function syncModelForAllocSet(allocSetName,modelName)



    appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
    allocSet=appCatalog.getAllocationSet(allocSetName);
    if strcmp(allocSet.p_SourceModel.p_ModelURI,modelName)
        allocSet.p_SourceModel.syncChanges;
    elseif strcmp(allocSet.p_TargetModel.p_ModelURI,modelName)
        allocSet.p_TargetModel.syncChanges;
    end

end

