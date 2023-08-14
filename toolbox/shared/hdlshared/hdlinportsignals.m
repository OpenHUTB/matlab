function signals=hdlinportsignals


    if hdlispirbased

        hDriver=hdlcurrentdriver;
        hN=hDriver.getCurrentNetwork;
        signals=hN.getInputPortSignals;
        signals=signals(:)';
    else
        signalTable=hdlgetsignaltable;
        signals=signalTable.getInportIndices;
    end
end

