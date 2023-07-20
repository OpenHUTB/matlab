function newComp=elaborate(~,hN,hC)


    if~hC.PirInputSignals.Type.isRecordType

        newComp=pirelab.getWireComp(hN,hC.PirInputSignals,hC.PirOutputSignals);
        return;
    end

    newComp=pirelab.getBustoVectorComp(hN,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);
end
