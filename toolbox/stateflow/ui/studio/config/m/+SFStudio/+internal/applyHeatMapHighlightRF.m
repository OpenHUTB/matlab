function applyHeatMapHighlightRF(cbInfo,action)




    [machineName]=SFStudio.internal.extractMachineInfo(cbInfo);
    if isempty(machineName)
        retun;
    end
    action.enabled=Stateflow.HeatMap.HeatMapToolStripManager.isHeatMapOnByUserFor(machineName);
    if action.enabled
        action.selected=Stateflow.HeatMap.HeatMapToolStripManager.isShowHighlightOnCanvasEnabled(machineName);
    end
end
