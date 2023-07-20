



function flipBlockNameRF(cbinfo,action)
    if~SLStudio.Utils.selectionHasBlocks(cbinfo)||SLStudio.Utils.isLockedSystem(cbinfo)||Simulink.internal.isArchitectureModel(cbinfo)
        action.enabled=false;
    end
end