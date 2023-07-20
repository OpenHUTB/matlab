function hNewC=lowerDspba(hN,hC)




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

    for i=1:length(hC.getResetNames)
        portName=hC.getResetNames{i};
        if~isempty(portName)
            hP=hC.addInputPort('reset',portName);
            reset.addReceiver(hP);
        end
    end

    for i=1:length(hC.getBusInputPortNames)
        portName=hC.getBusInputPortNames{i};
        if~isempty(portName)
            hT=hN.getType('FixedPoint','Signed',0,'WordLength',hC.getBusInputPortWidths{i});
            hS=hN.addSignal(hT,'GND');
            hP=hC.addInputPort('data',portName);
            hS.addReceiver(hP);
            pireml.getConstComp(hN,hS,0,'GND');
        end
    end

    for i=1:length(hC.getBusReadEnablePortNames)
        portName=hC.getBusReadEnablePortNames{i};
        if~isempty(portName)
            hT=hN.getType('FixedPoint','Signed',0,'WordLength',1);
            hS=hN.addSignal(hT,'HIGH');
            hP=hC.addInputPort('data',portName);
            hS.addReceiver(hP);
            pireml.getConstComp(hN,hS,1,'HIGH');
        end
    end

    hNewC=hC;
end


