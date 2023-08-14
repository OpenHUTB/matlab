

function format=getDisplayBlockFormat(msg)
    switch msg
    case DAStudio.message('SimulinkHMI:dashboardblocks:SHORT')
        format=int32(3);
    case DAStudio.message('SimulinkHMI:dashboardblocks:LONG')
        format=int32(4);
    case DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_E')
        format=int32(5);
    case DAStudio.message('SimulinkHMI:dashboardblocks:LONG_E')
        format=int32(6);
    case DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_G')
        format=int32(7);
    case DAStudio.message('SimulinkHMI:dashboardblocks:LONG_G')
        format=int32(8);
    case DAStudio.message('SimulinkHMI:dashboardblocks:SHORT_ENG')
        format=int32(9);
    case DAStudio.message('SimulinkHMI:dashboardblocks:LONG_ENG')
        format=int32(10);
    case DAStudio.message('SimulinkHMI:dashboardblocks:BANK')
        format=int32(11);
    case DAStudio.message('SimulinkHMI:dashboardblocks:PLUS')
        format=int32(12);
    case DAStudio.message('SimulinkHMI:dashboardblocks:HEX')
        format=int32(13);
    case DAStudio.message('SimulinkHMI:dashboardblocks:RAT')
        format=int32(14);
    case DAStudio.message('SimulinkHMI:dashboardblocks:CUSTOM')
        format=int32(15);
    case DAStudio.message('SimulinkHMI:dashboardblocks:INTEGER')
        format=int32(16);
    otherwise
        warning(DAStudio.message('SimulinkHMI:errors:InvalidFormatEnum'));
    end
end
