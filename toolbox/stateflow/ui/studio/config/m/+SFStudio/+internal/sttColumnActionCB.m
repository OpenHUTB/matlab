function sttColumnActionCB(userData,cbinfo)
    chartId=SFStudio.Utils.getChartId(cbinfo);
    sttman=Stateflow.STT.StateEventTableMan(chartId);
    si=sttman.viewManager.CurrentSelectionInfo;
    COLUMN_OFFSET=-1;
    SFStudio.Utils.executeActionOnSTTUI(cbinfo,userData,{si.ColumnIndex+COLUMN_OFFSET});
end