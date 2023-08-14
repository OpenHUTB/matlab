
function muxOutSignal=muxInputSignal(hN,inputSignal,dimLen,compName)
    hInSignals=repmat(inputSignal,dimLen,1);
    vecType=pirelab.getPirVectorType(inputSignal.Type,dimLen);
    muxOutSignal=hN.addSignal(vecType,sprintf('%s_in_mux',compName));
    muxOutSignal.SimulinkRate=hInSignals(1).SimulinkRate;
    pirelab.getMuxComp(hN,hInSignals,muxOutSignal);
end