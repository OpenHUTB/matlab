function hdlsetcurrentclockenable(idx)


    if hdlispirbased



        if~isempty(idx)
            hN=idx.Owner;
            cs=hN.getEffectiveControlSignal('clock_enable');
            if~isempty(cs)
                idx=cs;
            end
        end

        hDriver=hdlcurrentdriver;
        hDriver.CurrentClockEnable=idx;
        hDriver.HasClockEnable=~isempty(idx);
    else
        signalTable=hdlgetsignaltable;
        if isempty(idx)
            signalTable.CurrentClockEnable=-1;
        elseif hdlisclockenablesignal(idx)
            signalTable.CurrentClockEnable=idx;
        else
            error(message('HDLShared:directemit:notaclockenable',hdlsignalname(idx)));
        end
    end
end
