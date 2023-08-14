function symbol=getExecTimeProbeSymbol(key)




    switch key
    case 'start'
        symbol=Simulink.ExecTimeTraceabilityProbes.BlockStartSymbol;
    case 'end'
        symbol=Simulink.ExecTimeTraceabilityProbes.BlockEndSymbol;
    case 'declarations'
        symbol=Simulink.ExecTimeTraceabilityProbes.DeclarationsPlaceholderSymbol;
    case 'customTraceIdentifier'
        symbol=Simulink.ExecTimeTraceabilityProbes.CustomTraceIdentifier;
    otherwise
        symbol='';
    end
    assert(~isempty(symbol),'Symbol must not be empty');
