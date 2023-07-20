function hNewInstance=elaborate(~,hN,hC)


    ramName='DualRateDualPortRAM';

    [~,hNewInstance]=pirelab.getDualRateDualPortRamComp(hN,hC.PIRInputSignals,...
    hC.PirOutputSignals,ramName,1,hC.SimulinkHandle);
end
