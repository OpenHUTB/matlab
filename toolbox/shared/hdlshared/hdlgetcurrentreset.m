function idx=hdlgetcurrentreset


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        idx=hDriver.CurrentReset;
    else
        signalTable=hdlgetsignaltable;
        idx=signalTable.CurrentReset;
        if idx==-1
            idx=[];
        end
    end
end
