function logSimulationStatisticsCB(cbinfo,action)





    mdlHandle=simscape.internal.sl_toolstrip.getModelHandle(cbinfo);
    if(~isempty(mdlHandle))
        if(strcmp(get_param(mdlHandle,'SimscapeLogSimulationStatistics'),'off'))
            set_param(mdlHandle,'SimscapeLogSimulationStatistics','on');
            action.selected=1;
        else
            set_param(mdlHandle,'SimscapeLogSimulationStatistics','off');
            action.selected=0;
        end
    end

end