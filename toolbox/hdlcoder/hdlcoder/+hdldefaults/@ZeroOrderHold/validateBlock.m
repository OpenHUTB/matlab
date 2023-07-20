function v=validateBlock(this,hC)




    v=hdlvalidatestruct;

    in=hC.SLInputPorts(1).Signal;
    out=hC.SLOutputPorts(1).Signal;

    ip_samp_time=hdlsignalrate(in);
    op_samp_time=hdlsignalrate(out);


    if(ip_samp_time~=op_samp_time)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:FoundMultipleRatesRTC',hC.Name));
    end


