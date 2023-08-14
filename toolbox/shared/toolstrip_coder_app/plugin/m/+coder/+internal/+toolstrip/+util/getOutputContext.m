function context=getOutputContext(model)



    type=coder.internal.toolstrip.util.getOutputType(model);
    switch type
    case 'ert'
        context='embeddedCCodeContext';
    case 'cpp'
        context='embeddedCPlusPlusCodeContext';
    case 'ert_shrlib'
        context='embeddedSharedLibraryCodeContext';
    case 'sldrtert'
        context='embeddedDesktopRealTimeContext';
    case 'systemverilog_dpi_ert'
        context='embeddedSystemVerilogContext';
    case 'tlmgenerator_ert'
        context='embeddedSystemTLMContext';

    case 'grt'
        context='genericCCodeContext';
    case 'grt_cpp'
        context='genericCPlusCPlusCodeContext';
    case 'slrt'
        context='genericSimulinkRealTimeContext';
    case 'sldrt'
        context='genericDesktopRealTimeContext';
    case 'realtime'
        context='genericTargetHardwareContext';
    case 'rtwsfcn'
        context='genericSFunctionRtwContext';
    case 'rsim'
        context='genericRapidSimuliationRSimContext';
    case 'systemverilog_dpi_grt'
        context='genericSystemVerilogContext';
    case 'tlmgenerator_grt'
        context='genericSystemTLMContext';
    case 'asap2'
        context='genericASAPContext';
    otherwise
        context='customCodeContext';
    end
