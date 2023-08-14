function hNewC=elaborate(this,hN,hC)



    hNewNet=createNetworkWithComponent(hN,hC);

    pirelab.getDeserializerComp(hNewNet,hNewNet.PirInputSignals,hNewNet.PirOutputSignals,hC.Name);

    hNewC=pirelab.instantiateNetwork(hN,hNewNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

    hNewNet.flattenAfterModelgen;


end




function hNewNet=createNetworkWithComponent(hN,hC)

    hNewNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC);



    for ii=1:length(hC.PirInputSignals)
        hNewNet.PirInputSignals(ii).SimulinkRate=hC.PirInputSignals(ii).SimulinkRate;
    end

    for ii=1:length(hC.PirOutputSignals)
        hNewNet.PirOutputSignals(ii).SimulinkRate=hC.PirOutputSignals(ii).SimulinkRate;
    end
end




