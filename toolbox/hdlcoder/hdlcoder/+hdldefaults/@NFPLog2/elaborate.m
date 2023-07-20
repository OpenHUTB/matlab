function hNewC=elaborate(this,hN,blockComp)


    slbh=blockComp.SimulinkHandle;
    hInSignals=blockComp.PirInputSignals;
    hOutSignals=blockComp.PirOutputSignals;


    fname='log2';
    nfpOptions=getNFPBlockInfo(this);

    hNewC=pirelab.getMathComp(hN,hInSignals,hOutSignals,blockComp.Name,...
    slbh,fname,nfpOptions);
end
