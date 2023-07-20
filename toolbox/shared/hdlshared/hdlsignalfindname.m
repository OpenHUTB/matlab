function idx=hdlsignalfindname(signalname)


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        hN=hDriver.getCurrentNetwork;
        idx=hN.findSignal('Name',signalname);
        if isempty(idx)
            error(message('HDLShared:directemit:unknownsignal',signalname));
        end
    else
        signalTable=hdlgetsignaltable;
        idx=signalTable.findSignalFromName(signalname);
    end
end
