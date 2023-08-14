function hdllastinputsignal



    if hdlispirbased
        error(message('HDLShared:directemit:slhdlcodercall',mfilename));
    end

    signalTable=hdlgetsignaltable;
    signalTable.addInportSignal(1:(signalTable.NextSignalIndex-1));
end
