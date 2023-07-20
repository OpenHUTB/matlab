function logSimulationStatisticsRF(cbinfo,action)





    if isempty(simscape.internal.sl_toolstrip.getSelectedBlock(cbinfo))
        action.enabled=false;
        return;
    end
    action.enabled=true;

    mdlHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);
    if(~isempty(mdlHandle))
        if(get_param(mdlHandle,'SimscapeLogType')=="none")
            action.enabled=0;
        else
            action.enabled=1;

            if(get_param(mdlHandle,'SimscapeLogSimulationStatistics')=="off")
                action.selected=0;
            else
                action.selected=1;
            end
        end
    end
end