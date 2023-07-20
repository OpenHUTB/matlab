function hNewC=lowerXsgVivado(hN,hC)




    hT=hN.getType('Boolean');
    hS=hN.addSignal(hT,'dummy');
    hS.SimulinkRate=hC.getBaseRate;
    [clock,clken,reset]=hN.getClockBundle(hS,1,1,0);
    hN.removeSignal(hS);



    assert(numel(hC.getClkNames)==1);
    portName=hC.getClkNames{1};
    if~isempty(portName)
        hP=hC.addInputPort('clock',portName);
        clock.addReceiver(hP);
    end
    portName=hC.getCeNames{1};
    if~isempty(portName)
        hP=hC.addInputPort('clock_enable',portName);
        clken.addReceiver(hP);
    end
    portName=hC.getResetNames{1};
    if~isempty(portName)
        hP=hC.addInputPort('reset',portName);
        reset.addReceiver(hP);
    end

    hNewC=hC;
end
