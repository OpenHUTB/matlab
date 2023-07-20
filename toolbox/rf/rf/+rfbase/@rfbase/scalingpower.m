function[pname,pdata,punit]=scalingpower(h,in,format,power_type)





    pname='';
    pdata=[];
    punit='';

    if isempty(in)
        return
    end

    switch upper(power_type)
    case 'PIN'
        pname='P_{in}';
    case 'POUT'
        pname='P_{out}';
    end


    switch upper(format)
    case 'DBM'
        pdata=10*log10(in)+30;
        punit='[dBm]';
    case 'DBW'
        pdata=10*log10(in);
        punit='[dBw]';
    case 'MW'
        pdata=1000*in;
        punit='[mW]';
    case 'W'
        pdata=in;
        punit='[W]';
    otherwise
        pdata=10*log10(in)+30;
        punit='[dBm]';
    end