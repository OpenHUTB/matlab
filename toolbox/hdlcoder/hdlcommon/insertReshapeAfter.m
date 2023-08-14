function insertReshapeAfter(hN,hC,dims)
    hCSignals=hC.PirOutputSignals;
    hCPorts=hC.PirOutputPorts;




    for ii=1:length(hCSignals)
        ht=hCSignals(ii).Type;
        hBaseT=ht.BaseType;


        vectorType=pirelab.createPirArrayType(hBaseT,dims);
        flattenedVectorSignal=hN.addSignal(vectorType,[hCSignals(ii).Name,'_flattenedVector']);
        flattenedVectorSignal.SimulinkRate=hCSignals(ii).SimulinkRate;

        arrayType=pirelab.createPirArrayType(hBaseT,hCSignals(ii).Type.Dimensions);
        newSignal=hN.addSignal(arrayType,[hCSignals(ii).Name,'_reshape']);
        newSignal.SimulinkRate=hCSignals(ii).SimulinkRate;


        hCSignals(ii).disconnectDriver(hCPorts(ii));


        newC=pirelab.getReshapeComp(hN,flattenedVectorSignal,newSignal);
        newC.setShouldDraw(true);

        newC.PirInputSignals.disconnectDriver(newC.PirOutputPorts)
        flattenedVectorSignal.addDriver(hCPorts(ii));
        hCSignals(ii).addDriver(newC.PirOutputPorts);
    end
end
