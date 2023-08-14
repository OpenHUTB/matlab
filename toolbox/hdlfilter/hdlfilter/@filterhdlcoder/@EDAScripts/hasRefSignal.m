function result=hasRefSignal(this,SignalName)





    result=false;
    idx=hdlsignalfindname(SignalName);
    if hdlgetparameter('tbrefsignals')&&isfilter_outsignal(idx)
        result=true;
    end


    function yes=isfilter_outsignal(signal)

        yes=strcmp(hdlsignalname(signal),hdlgetparameter('filter_output_name'))||...
        strcmp(hdlsignalname(signal),[hdlgetparameter('filter_output_name'),hdlgetparameter('complex_imag_postfix')])||...
        strcmp(hdlsignalname(signal),[hdlgetparameter('filter_output_name'),hdlgetparameter('complex_real_postfix')]);




