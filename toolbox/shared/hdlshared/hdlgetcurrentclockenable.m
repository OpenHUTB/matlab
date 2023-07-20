function idx=hdlgetcurrentclockenable


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        idx=hDriver.CurrentClockEnable;
    else
        signalTable=hdlgetsignaltable;
        idx=signalTable.CurrentClockEnable;

        if idx==-1
            idx=[];
        end
    end
end
