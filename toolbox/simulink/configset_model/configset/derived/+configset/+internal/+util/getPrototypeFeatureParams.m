
function features=getPrototypeFeatureParams(component)
    switch(component)
    case 'AUTOSAR.AUTOSARAdaptiveTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'MDX.MDXTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'RTW.RSimTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'RTW.TornadoTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'CPPClassGenComp'
        features={};
    case 'SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'SimulinkDesktopRealTime.SimulinkDesktopRealTimeERTCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'SimulinkRealTime.SimulinkRealTimeCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'SimulinkRealTime.SimulinkRealTimeERTCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'dpigen.DPIERTTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'dpigen.DPIGRTTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'Simulink.ERTTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'Simulink.GRTTargetCC'
        features={{'ExtModeXCPMemoryConfiguration',{'ExtModeAutomaticAllocSize','ExtModeMaxTrigDuration'}};{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'pjtgeneratorpkg.ERTFactory'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'pjtgeneratorpkg.GRTFactory'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'Simulink.RaccelTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'slrealtime.SimulinkRealTimeTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'slrtlinux.slrtlinuxTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'tlmg.TLMERTTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'tlmg.TLMGRTTargetCC'
        features={{'ReductionsWithSimdParam',{'OptimizeReductions'}}};
    case 'Host-Target Communication'
        features={};
    case 'RTDX Configuration'
        features={};
    case 'Coder Target'
        features={};
    case 'SimscapeMultibody1G'
        features={};
    case 'Model Advisor'
        features={};
    case 'PLC Coder'
        features={{'PLCExternallyDefinedBlocks',{'PLC_ExternalDefinedBlocks'}};{'PLCExternallyDefinedBlocks2',{'PLC_ExcludeBlocksAsFunction','PLC_ExcludeBlocksAsFunctionBlock'}}};
    case 'realtime'
        features={};
    case 'Simscape'
        features={};
    case 'Simulink Coverage'
        features={};
    case 'Design Verifier'
        features={};
    case 'HDL Coder'
        features={{'StreamingMatrixWorkflow',{'FrameToSampleConversion','SamplesPerCycle','InputFIFOSize','OutputFIFOSize'}}};
    case 'Target Hardware Resources'
        features={};
    case 'Polyspace'
        features={};
    case 'SimscapeMultibody'
        features={};
    case 'DiagnosticsConfigSet'
        features={};
    case 'ExplorerConfigSet'
        features={};
    case{'Simulink.STFCustomTargetCC','Simulink.RaccelTargetCC'}
        features={};
    otherwise
        features=configset.internal.util.getCustomComponentFeatureList(component);
    end
end