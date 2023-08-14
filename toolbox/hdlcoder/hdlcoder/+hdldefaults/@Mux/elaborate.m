function hNewC=elaborate(this,hN,hC)



    hCInSignals=hC.SLInputSignals;
    hCOutSignals=hC.SLOutputSignals;

    hNewC=pirelab.getMuxComp(hN,hCInSignals,hCOutSignals);

end
