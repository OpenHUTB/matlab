function hNewC=elaborate(this,hN,hC)



    hInSignals=hC.PirInputSignals;
    hOutSignals=hC.PirOutputSignals;


    newtonInfo=getBlockInfo(this,hC.SimulinkHandle);


    hNewtonNet=pirelab.getRecipSqrtNewtonSingleRateNetwork(hN,hInSignals,hOutSignals,newtonInfo);


    hNewC=pirelab.instantiateNetwork(hN,hNewtonNet,hInSignals,hOutSignals,hC.Name);

end
