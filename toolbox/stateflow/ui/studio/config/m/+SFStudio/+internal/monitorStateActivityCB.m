function monitorStateActivityCB(cbinfo,varargin)
    objectH=cbinfo.getSelection();
    if isempty(objectH)
        chartId=SFStudio.Utils.getChartId(cbinfo);
        objectH=sf('IdToHandle',chartId);
    end
    chartH=sf('IdToHandle',(sfprivate('getChartOf',objectH.id)));
    if chartH.HasOutputData&&...
        strcmp(cbinfo.userdata.monitoringMode,chartH.OutputMonitoringMode)==1
        chartH.HasOutputData=false;
    else

        chartH.HasOutputData=true;
        chartH.OutputMonitoringMode=cbinfo.userdata.monitoringMode;
    end
end