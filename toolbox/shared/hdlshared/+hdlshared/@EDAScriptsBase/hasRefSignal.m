function result=hasRefSignal(this,SignalName)





    result=false;
    idx=hdlsignalfindname(SignalName);
    if hdlgetparameter('tbrefsignals')&&hdlisoutportsignal(idx)&&~isSyntheticSignal(idx)&&~(idx.isClockEnable)
        result=true;
    end





    function synthetic=isSyntheticSignal(signal)
        synthetic=strcmp(hdlsignalname(signal),hdlgetparameter('clockenableoutputname'));

