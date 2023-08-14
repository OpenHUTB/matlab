function hNewC=elaborate(this,hN,hC)



    hCInSignal=hC.PirInputSignals;
    hCOutSignal=hC.PirOutputSignals;

    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);


    this.elaborateCascadeSum(hNewNet,hC);

    hNewC=pirelab.instantiateNetwork(hN,hNewNet,hCInSignal,hCOutSignal,hC.Name);

