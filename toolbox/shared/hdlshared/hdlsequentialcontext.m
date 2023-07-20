function val=hdlsequentialcontext(arg)


    if hdlispirbased
        hDriver=hdlcurrentdriver;
        if nargin==1
            hDriver.SequentialContext=logical(arg);
        end
        val=hDriver.SequentialContext;
    else
        signalTable=hdlgetsignaltable;
        if nargin==1
            signalTable.IsSequentialContext=logical(arg);
        end
        val=signalTable.IsSequentialContext;
    end
end
