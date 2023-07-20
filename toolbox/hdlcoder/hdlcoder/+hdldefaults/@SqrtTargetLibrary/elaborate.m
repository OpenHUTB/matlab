function hNewC=elaborate(this,hN,blockComp)




    hInSignals=blockComp.PirInputSignals;
    hOutSignals=blockComp.PirOutputSignals;
    fname=get_param(blockComp.SimulinkHandle,'Function');
    nfpOptions=getNFPBlockInfo(this);
    hNewC=pirelab.getSqrtComp(hN,hInSignals,hOutSignals,blockComp.Name,...
    blockComp.SimulinkHandle,fname,nfpOptions);
