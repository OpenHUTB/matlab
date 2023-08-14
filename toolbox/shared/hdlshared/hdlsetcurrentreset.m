function hdlsetcurrentreset(idx)


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        hDriver.CurrentReset=idx;
    else
        signalTable=hdlgetsignaltable;
        if isempty(idx)
            signalTable.CurrentReset=-1;
        elseif hdlisresetsignal(idx)
            signalTable.CurrentReset=idx;
        else
            error(message('HDLShared:directemit:notareset',hdlsignalname(idx)));
        end
    end
end
