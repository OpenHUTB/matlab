function last=hdllastsignal



    if hdlispirbased
        error(message('HDLShared:directemit:slhdlcodercall',mfilename));
    end

    signalTable=hdlgetsignaltable;
    last=signalTable.NextSignalIndex-1;
end
