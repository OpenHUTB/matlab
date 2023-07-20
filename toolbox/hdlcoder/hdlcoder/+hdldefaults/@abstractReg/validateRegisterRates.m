function[status,msg]=validateRegisterRates(this,hC)






    in=hC.SLInputPorts(1).Signal;
    out=hC.SLOutputPorts(1).Signal;

    ip_samp_time=hdlsignalrate(in);
    op_samp_time=hdlsignalrate(out);


    status=0;
    msg='';

    bothZero=all([ip_samp_time,op_samp_time]==0);
    bothInf=all([ip_samp_time,op_samp_time]==Inf);

    anyZero=any([ip_samp_time,op_samp_time]==0);
    anyInf=any([ip_samp_time,op_samp_time]==Inf);

    if bothZero||bothInf
        status=1;
        msg=['Cannot find valid sample time for clock request from block %s--please ensure that the block has a valid discrete sample time'];
    elseif~anyZero&&~anyInf
        if(ip_samp_time~=op_samp_time)&&~(bothZero||bothInf)
            status=1;
            msg=['Different input and output rates are not supported for this block. Add rate transition block.'];
        end
    end
