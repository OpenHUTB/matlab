function hdlregsignal(signal,realonly)


    if nargin<2
        realonly=false;
    end

    regsignalhelper(signal)
    if~realonly&&hdlsignaliscomplex(signal)
        regsignalhelper(hdlsignalimag(signal));
    end
end


function regsignalhelper(signal)
    if hdlispirbased
        signal.Reg=true;
    else
        if hdlgetparameter('isverilog')&&~hdlisinportsignal(signal)&&~hdlisoutportsignal(signal)
            vtype=hdlsignalvtype(signal);
            if strcmp(vtype(1:4),hdlgetparameter('base_data_type'))
                hdlsignalsetvtype(signal,[hdlgetparameter('reg_data_type'),vtype(5:end)]);
            end
        end
    end
end
