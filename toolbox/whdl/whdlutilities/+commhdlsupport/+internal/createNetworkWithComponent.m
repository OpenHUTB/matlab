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
