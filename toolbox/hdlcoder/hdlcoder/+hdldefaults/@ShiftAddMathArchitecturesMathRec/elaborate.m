function hNewC=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);
    hC.Name='reciprocal';
    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;
    hNewC=pirelab.getNonRestoreReciprocalComp(hN,hInSignals,hOutSignals,blockInfo);

end
