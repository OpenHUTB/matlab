function viewHeatMapTableRF(cbInfo,action)




    [machineName]=SFStudio.internal.extractMachineInfo(cbInfo);
    action.enabled=Stateflow.HeatMap.HeatMapToolStripManager.isHeatMapOnByUserFor(machineName);
    if action.enabled
        studioTag=cbInfo.studio.getStudioTag;
        action.selected=Stateflow.HeatMap.HeatMapToolStripManager.isShowTableEnabled(studioTag);
    end
end
