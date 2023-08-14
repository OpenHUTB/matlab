function hNewInstance=elaborate(this,hN,hC)


    [RAMType,readNewData,IVStr,numBanks,RAMDirective]=this.getBlockInfo(hC);

    if numBanks>1
        hRAMNet=pirelab.createNewNetworkWithInterface(...
        'Network',hN,...
        'RefComponent',hC);
        inputSignals=hRAMNet.PirInputSignals;
        outputSignals=hRAMNet.PirOutputSignals;
    else
        hRAMNet=hN;
        inputSignals=hC.PirInputSignals;
        outputSignals=hC.PirOutputSignals;
    end
    if strcmp(RAMType,'Dual port')&&length(outputSignals)==1

        writeOutputType=hC.PirOutputSignals(1).Type;
        readOutputSignal=hRAMNet.addSignal(writeOutputType,...
        [hC.Name,'_read_out']);
        outputSignals(2)=readOutputSignal;
    end

    switch(RAMType)
    case 'Single port'
        [~,hNewInstance]=pirelab.getSinglePortRamComp(hRAMNet,...
        inputSignals,outputSignals,'',numBanks,readNewData,...
        hC.SimulinkHandle,IVStr,RAMDirective);
    case 'Simple dual port'
        [~,hNewInstance]=pirelab.getSimpleDualPortRamComp(hRAMNet,...
        inputSignals,outputSignals,'',numBanks,hC.SimulinkHandle,...
        [],[],IVStr,RAMDirective);
    case 'Dual port'
        [~,hNewInstance]=pirelab.getDualPortRamComp(hRAMNet,...
        inputSignals,outputSignals,'',numBanks,readNewData,...
        hC.SimulinkHandle,IVStr,RAMDirective);
    end

    if hN~=hRAMNet
        hNewInstance=pirelab.instantiateNetwork(hN,hRAMNet,hC.PirInputSignals,...
        hC.PirOutputSignals,hC.Name);
        hRAMNet.flattenAfterModelgen;
    end

end


