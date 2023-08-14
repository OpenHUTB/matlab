function elaborateVHTAdapterIn(~,hElab,~,...
    hN,hStreamNetInportSignals,hStreamNetOutportSignals)




    networkName=sprintf('%s_adapter_in',hElab.TopNetName);




    hN_adapter=pirelab.createNewNetwork(...
    'PirInstance',hElab.BoardPirInstance,...
    'Network',hN,...
    'Name',networkName,...
    'InportSignals',hStreamNetInportSignals,...
    'OutportSignals',hStreamNetOutportSignals...
    );


    [~,clkenb,~]=hN_adapter.getClockBundle(hN_adapter.PirInputSignals(1),1,1,0);


    enable_port=hN_adapter.PirInputSignals(9);
    pirelab.getWireComp(hN_adapter,enable_port,clkenb);

    moduleNetworkName=sprintf('%s_adapter_in_module',hElab.TopNetName);
    pirtarget.getVHTAdapterInNetwork(hN_adapter,hN_adapter.PirInputSignals(1:8),hN_adapter.PirOutputSignals,moduleNetworkName);

    pirelab.instantiateNetwork(hN,hN_adapter,hStreamNetInportSignals,hStreamNetOutportSignals,hN_adapter.Name);

end


