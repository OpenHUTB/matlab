function[isSTT,sttId]=isStateTransitionTable(cbinfo)
    sttId=0;
    isSTT=false;
    if isa(cbinfo.domain,'StateflowDI.SFDomain')
        chartId=SFStudio.Utils.getChartId(cbinfo);
        isSTT=chartId&&sfprivate('is_state_transition_table_chart',chartId);
        if(isSTT)
            sttId=chartId;
        end
    end
end