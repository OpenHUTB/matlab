function hNewC=lowerMegaFunction(hN,hC)


    [clock,clken,reset]=hN.getClockBundle(hC.PirOutputSignals(1),1,1,0);



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

    hNewC=hC;
end


