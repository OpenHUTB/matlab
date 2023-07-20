function hNewC=elaborate(~,hN,hC)


    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,'RefComponent',hC);


    pirelab.getTransposeComp(hNewNet,hNewNet.PirInputSignals,...
    hNewNet.PirOutputSignals,hC.Name);
    hNewC=pirelab.instantiateNetwork(hN,hNewNet,hC.PirInputSignals,...
    hC.PirOutputSignals,hC.Name);
    hNewNet.flattenAfterModelgen;
end
