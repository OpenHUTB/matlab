function configureXCPExtModeSimulationTime(hCS,type)






    if isequal(type,'SimulationTimeInTicks')
        tlcOpts=get_param(hCS,'TLCOptions');

        tlcOpts=[tlcOpts,' -aExtModeXCPSimulationTimeInTicks=1'];
        set_param(hCS,'TLCOptions',tlcOpts);
    end
end