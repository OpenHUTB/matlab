function launchProfileDialog(allocSetName)



    appCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
    cbinfo.allocSet=appCatalog.getAllocationSet(allocSetName);

    systemcomposer.allocation.internal.ManageAllocationSetProfiles.launch(cbinfo);
end

