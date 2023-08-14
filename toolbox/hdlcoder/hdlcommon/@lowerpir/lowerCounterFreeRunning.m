function hNewC=lowerCounterFreeRunning(hN,hC)




    hOutSignal=hC.PirOutputSignals(1);
    outputRate=hOutSignal.SimulinkRate;

    hNewC=pireml.getCounterFreeRunningComp(...
    hN,...
    hOutSignal,...
    outputRate,...
    hC.Name);

end
