function insertReshapeBefore(hN,hC,dims)
    hCSignals=hC.PirInputSignals;
    hCPorts=hC.PirInputPorts;



    for ii=1:length(hCSignals)
        ht=hCSignals(ii).Type;
        hBaseT=ht.BaseType;

        arrayType=pirelab.createPirArrayType(hBaseT,dims);
        newSignal=hN.addSignal(arrayType,[hCSignals(ii).Name,'_reshape']);

        newSignal.SimulinkRate=hCSignals(ii).SimulinkRate;
        hCSignals(ii).disconnectReceiver(hCPorts(ii));
        newC=pirelab.getReshapeComp(hN,hCSignals(ii),newSignal);
        newC.setShouldDraw(true);
        newSignal.addReceiver(hCPorts(ii));
    end
end
