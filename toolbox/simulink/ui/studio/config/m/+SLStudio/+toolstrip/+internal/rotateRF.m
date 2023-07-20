



function rotateRF(cbinfo,action)
    if~SLStudio.Utils.selectionHasBlocks(cbinfo)||...
        SLStudio.Utils.isLockedSystem(cbinfo)||...
        SLStudio.Utils.isPanelWebBlock(cbinfo)||...
        Simulink.internal.isArchitectureModel(cbinfo)

        if~SLStudio.toolstrip.internal.onlyImagesSelected(cbinfo)
            action.enabled=false;
        end
    end
end