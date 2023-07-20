function applyHeatMapHighlightCB(cbInfo)




    [machineName,~,chartHandle]=SFStudio.internal.extractMachineInfo(cbInfo);
    Stateflow.HeatMap.HeatMapToolStripManager.toggleIsShowHighlightOnCanvasEnabled(machineName,cbInfo.EventData);
    value=cbInfo.EventData;
    if value
        Stateflow.HeatMap.HeatMapUIManager.applyHighlightOnCanvas(chartHandle.Path);
    else
        Stateflow.HeatMap.HeatMapUIManager.clearHighlighting(chartHandle.Machine.Id);
    end

end
