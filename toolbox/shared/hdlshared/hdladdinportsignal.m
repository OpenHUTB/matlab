function hdladdinportsignal(idx)


    if hdlispirbased
        error(message('HDLShared:directemit:slhdlcodercall',mfilename));
    end

    signalTable=hdlgetsignaltable;
    signalTable.checkSignalIndices(idx);
    signalTable.addInportSignal(idx);

    if(hdlsignaliscomplex(idx))
        cidx=hdlsignalimag(idx);
        signalTable.checkSignalIndices(cidx);
        signalTable.addInportSignal(cidx);
    end
end
