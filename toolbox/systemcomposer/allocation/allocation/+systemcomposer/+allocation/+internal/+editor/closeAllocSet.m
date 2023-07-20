function closeAllocSet(allocSetName,force)



    appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
    appCatalog.closeAllocationSet(allocSetName,force);

end

