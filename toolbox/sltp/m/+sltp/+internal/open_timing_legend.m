function open_timing_legend(mdl)





    open_system(mdl);

    st=get_param(mdl,'SampleTimes');
    if isempty(st)

        set_param(mdl,'SimulationCommand','Update');
    end

    mdlName=get_param(mdl,'Name');
    legend=Simulink.SampleTimeLegend;
    legend.showLegend(mdlName);

end
