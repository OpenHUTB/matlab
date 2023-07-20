function signals=hdloutportsignals


    if hdlispirbased

        hDriver=hdlcurrentdriver;
        hN=hDriver.getCurrentNetwork;
        signals=hN.getOutputPortSignals;
        signals=signals(:)';
    else
        signalTable=hdlgetsignaltable;
        signals=signalTable.getOutportIndices;
    end
end
