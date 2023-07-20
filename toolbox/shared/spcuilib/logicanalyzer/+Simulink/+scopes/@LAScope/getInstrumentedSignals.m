function[signals,sfsigs]=getInstrumentedSignals(model)


    signals=[];
    sfsigs=[];
    instr_signals=get_param(model,'InstrumentedSignals');
    if isempty(instr_signals)
        return;
    end
    num_signals=instr_signals.Count;
    signals=cell(1,num_signals);
    sfsigs=cell(1,num_signals);
    for kndx=1:num_signals
        k_signal=instr_signals.get(kndx);
        if Simulink.scopes.LAScope.isStateFlowSignal(k_signal)
            sfsigs{kndx}=k_signal.applyRebindingRules();
        else
            k_signal=k_signal.updatePortHandle;

            if(k_signal.PortHandle~=-1)

                signals{kndx}=k_signal;
            end
        end

    end
    signals=[signals{:}];
    sfsigs=[sfsigs{:}];
