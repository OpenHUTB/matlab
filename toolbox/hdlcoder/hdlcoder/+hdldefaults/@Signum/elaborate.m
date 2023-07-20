function hNewC=elaborate(this,hN,hC)




    nfpOptions=getNFPBlockInfo(this);

    hNewC=pirelab.getSignToNumComp(hN,hC.SLInputSignals,...
    hC.SLOutputSignals,hC.Name,hC.SimulinkHandle,nfpOptions);
end
