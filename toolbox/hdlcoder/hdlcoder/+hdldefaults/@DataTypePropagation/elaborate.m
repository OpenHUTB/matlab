function newComp=elaborate(this,hN,hC)



    slbh=hC.SimulinkHandle;
    newComp=pirelab.getNilComp(hN,hC.PirInputSignals,hC.PirOutputSignals,hC.Name,'',slbh);
    newComp.setDeletable(true);



