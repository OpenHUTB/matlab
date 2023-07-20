function val=hdlsignalnext


    if hdlispirbased
        error(message('HDLShared:directemit:slhdlcodercall',mfilename));
    end

    signalTable=hdlgetsignaltable;
    val=signalTable.getNextSignalIndex;
end
