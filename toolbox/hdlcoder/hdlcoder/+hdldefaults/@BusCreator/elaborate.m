function newComp=elaborate(~,hN,hC)


    busTypeStr=get_param(hC.SimulinkHandle,'OutDataTypeStr');
    compName=get_param(hC.SimulinkHandle,'Name');
    nonVirtualBus=get_param(hC.SimulinkHandle,'nonVirtualBus');

    newComp=pirelab.getBusCreatorComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    busTypeStr,nonVirtualBus,compName);
end
