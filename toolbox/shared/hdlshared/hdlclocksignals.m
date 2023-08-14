function signals=hdlclocksignals


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        signals=hDriver.getClockIndices;
    else
        signalTable=hdlgetsignaltable;
        signals=signalTable.getClockIndices;
    end
end
