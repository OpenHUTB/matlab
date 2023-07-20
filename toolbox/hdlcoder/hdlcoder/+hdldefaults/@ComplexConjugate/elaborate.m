function hNewC=elaborate(this,hN,hC)



    slbh=hC.SimulinkHandle;


    satMode=strcmpi(get_param(slbh,'SaturateOnIntegerOverflow'),'on');

    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);


    pirelab.getComplexConjugateComp(hNewNet,hC.SimulinkHandle,hNewNet.PirInputSignals,hNewNet.PirOutputSignals,satMode,hC.Name);

    hNewC=pirelab.instantiateNetwork(hN,hNewNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

    hNewNet.flattenAfterModelgen;

end
