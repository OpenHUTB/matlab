function sttTraceRF(cbinfo,action)
    action.enabled=false;
    chartId=SFStudio.Utils.getChartId(cbinfo);

    if Stateflow.STT.StateEventTableMan.isStateTransitionTable(chartId)
        sttman=Stateflow.STT.StateEventTableMan(chartId);
        selectionInfo=sttman.getSelectionInfo(chartId);
        if~isempty(selectionInfo)&&~ishandle(selectionInfo)&&...
            ~isempty(selectionInfo.HasBackendObject)&&selectionInfo.HasBackendObject==1
            action.enabled=true;
        end
    end
end
