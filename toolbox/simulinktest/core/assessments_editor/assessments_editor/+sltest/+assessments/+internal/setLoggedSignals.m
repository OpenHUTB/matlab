function currInstrumentedSignals=setLoggedSignals(model,harness,signals)
    [~,currInstrumentedSignals]=stm.internal.util.markOutputSignalsForStreaming(model,signals);
end

