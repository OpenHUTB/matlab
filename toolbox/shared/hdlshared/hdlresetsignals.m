function signals=hdlresetsignals


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        signals=hDriver.getResetIndices;
    else
        signalTable=hdlgetsignaltable;
        signals=signalTable.getResetIndices;
    end
end
