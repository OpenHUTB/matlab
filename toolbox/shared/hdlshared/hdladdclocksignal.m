function hdladdclocksignal(idx)


    if hdlispirbased
        error(message('HDLShared:directemit:slhdlcodercall',mfilename));
    end

    signalTable=hdlgetsignaltable;
    signalTable.checkSignalIndices(idx);
    signalTable.addClockSignal(idx);
end
