function hNewInstance=elaborate(this,hN,hC)


    ramName='SimpDualPortRAM';
    RAMDirective=getImplParams(this,'RAMDirective');

    [~,hNewInstance]=pirelab.getSimpleDualPortRamComp(hN,hC.PIRInputSignals,...
    hC.PirOutputSignals,ramName,1,hC.SimulinkHandle,[],'','',RAMDirective);
end


