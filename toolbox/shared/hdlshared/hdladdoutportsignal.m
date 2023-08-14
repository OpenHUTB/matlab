function hdladdoutportsignal(idx)


    if hdlispirbased
        error(message('HDLShared:directemit:slhdlcodercall',mfilename));
    end

    signalTable=hdlgetsignaltable;
    signalTable.checkSignalIndices(idx);
    signalTable.addOutportSignal(idx);
    if(hdlsignaliscomplex(idx))
        cidx=hdlsignalimag(idx);
        signalTable.checkSignalIndices(cidx);
        signalTable.addOutportSignal(cidx);
    end
end
