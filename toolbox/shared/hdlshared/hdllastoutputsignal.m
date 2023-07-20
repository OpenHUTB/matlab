function hdllastoutputsignal



    if hdlispirbased
        error(message('HDLShared:directemit:slhdlcodercall',mfilename));
    end

    signalTable=hdlgetsignaltable;
    inputs=signalTable.getInportIndices;
    outputs=(max(inputs)+1):(signalTable.NextSignalIndex-1);
    signalTable.addOutportSignal(outputs);
end

