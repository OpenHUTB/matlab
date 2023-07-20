function hNewInstance=elaborate(this,hN,hC)


    ramName='DualPortRAM';
    RAMDirective=getImplParams(this,'RAMDirective');

    [~,hNewInstance]=pirelab.getDualPortRamComp(hN,hC.PIRInputSignals,...
    hC.PirOutputSignals,ramName,1,1,hC.SimulinkHandle,'',RAMDirective);
end
