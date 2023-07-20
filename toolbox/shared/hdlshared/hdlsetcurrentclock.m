function hdlsetcurrentclock(idx)


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        hDriver.CurrentClock=idx;
    else
        signalTable=hdlgetsignaltable;

        if isempty(idx)
            signalTable.CurrentClock=-1;
        elseif hdlisclocksignal(idx)
            signalTable.CurrentClock=idx;
        else
            error(message('HDLShared:directemit:notaclock',hdlsignalname(idx)));
        end
    end
end
