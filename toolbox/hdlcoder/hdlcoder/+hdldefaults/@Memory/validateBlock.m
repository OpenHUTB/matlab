function v=validateBlock(~,hC)


    v=hdlvalidatestruct;

    in=hC.SLInputPorts(1).Signal;
    out=hC.SLOutputPorts(1).Signal;

    ip_samp_time=hdlsignalrate(in);
    op_samp_time=hdlsignalrate(out);



    bfp=hC.SimulinkHandle;
    inherit_samp_time_on=strcmpi(get_param(bfp,'InheritSampleTime'),'on');

    if(~inherit_samp_time_on||(ip_samp_time==0)||(op_samp_time==0))

        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:MemoryUnsupported'));
    end

