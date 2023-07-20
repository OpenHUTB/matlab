function idx=hdlgetcurrentclock


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        idx=hDriver.CurrentClock;
    else
        signalTable=hdlgetsignaltable;
        idx=signalTable.CurrentClock;
        if idx==-1
            idx=[];
        end
    end
end
