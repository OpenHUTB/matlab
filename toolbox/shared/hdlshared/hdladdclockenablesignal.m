function hdladdclockenablesignal(idx)


    if~hdlispirbased
        signalTable=hdlgetsignaltable;
        signalTable.checkSignalIndices(idx);
        signalTable.addClockEnableSignal(idx);
    end
end

