function rate=hdlsignalrate(idx)


    if hdlispirbased

        rate=idx.SimulinkRate;
    else
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        rate=signalTable.getRate(idx);
    end
end

