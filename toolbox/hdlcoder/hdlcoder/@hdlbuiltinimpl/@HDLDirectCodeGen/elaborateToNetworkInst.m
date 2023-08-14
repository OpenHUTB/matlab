function[hNewC,hNewNet]=elaborateToNetworkInst(~,hN,hC)














    hDriver=hdlcurrentdriver;
    hPir=hDriver.PirInstance;

    hNewNet=hPir.addNetwork;
    hNewNet.FullPath=[hN.Name,'/',hC.Name];
    hNewNet.Name=[hN.Name,'/',hC.Name];
    hNewNet.SimulinkHandle=-1;

    for ii=1:length(hC.SLInputPorts)
        hNewNet.addInputPort(hC.SLInputPorts(ii).Name);
    end

    for ii=1:length(hC.SLOutputPorts)
        hNewNet.addOutputPort(hC.SLOutputPorts(ii).Name);
    end

    block=hdlgetblocklibpath(hC.SimulinkHandle);
    if isempty(block)
        warning(message('hdlcoder:validate:tagnotfound',hC.Name));
    end


    hNewC=hNewNet.addComponent('block_comp',...
    length(hC.SLInputPorts),length(hC.SLOutputPorts),...
    block);
    hNewC.Name=hC.Name;
    hNewC.SimulinkHandle=hC.SimulinkHandle;

    cm=hDriver.getConfigManager(hDriver.ModelName);
    hNewC.setImplementation(cm.getDefaultImplementation(block));

    for ii=1:length(hC.SLInputPorts)
        insig=hC.SLInputPorts(ii).Signal;
        hsig=hNewNet.addSignal;
        hsig.Name=insig.Name;
        hsig.Type=insig.Type;
        hsig.VType(insig.VType);
        hsig.Imag(insig.Imag);
        hsig.SimulinkHandle=insig.SimulinkHandle;
        hsig.SimulinkRate=insig.SimulinkRate;
        hsig.addDriver(hNewNet,ii-1);
        hsig.addReceiver(hNewC,ii-1);
    end

    for ii=1:length(hC.SLOutputPorts)
        outsig=hC.SLOutputPorts(ii).Signal;
        hsig=hNewNet.addSignal;
        hsig.Name=outsig.Name;
        hsig.Type=outsig.Type;
        hsig.VType(outsig.VType);
        hsig.Imag(outsig.Imag);
        hsig.SimulinkHandle=outsig.SimulinkHandle;
        hsig.SimulinkRate=outsig.SimulinkRate;
        hsig.addDriver(hNewC,ii-1);
        hsig.addReceiver(hNewNet,ii-1);
    end

    hNetworkComp=hN.addComponent('ntwk_instance_comp',hNewNet);
    hNetworkComp.SimulinkHandle=hC.SimulinkHandle;

    hN.replaceComponent(hC,hNetworkComp);
end
