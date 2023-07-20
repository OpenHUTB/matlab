function signals=hdlclockenablesignals


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        signals=hDriver.getClockEnableIndices;
    else
        signalTable=hdlgetsignaltable;
        signals=signalTable.getClockEnableIndices;
    end
end
