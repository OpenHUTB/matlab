



function createSubsystemFromSelectionRF(userData,cbinfo,action)

    action.enabled=SLStudio.Utils.selectionHasBlocks(cbinfo);


    if~action.enabled&&strcmp(userData,'subsystem')
        selectedItem=SLStudio.Utils.getSingleSelection(cbinfo);
        action.enabled=SLStudio.Utils.objectIsValidArea(selectedItem);
    end
end
