function allocSet=load(fileName)



    appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
    allocSetImpl=appCatalog.loadAllocationSet(fileName,false);
    allocSet=systemcomposer.allocation.internal.getWrapperForImpl(allocSetImpl);
end

