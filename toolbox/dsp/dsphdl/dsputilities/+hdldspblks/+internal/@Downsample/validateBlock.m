function v=validateBlock(this,hC)


    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;






    in=hC.SLInputPorts(1).Signal;

    ip_samp_time=hdlsignalrate(in);

    if ip_samp_time==0||ip_samp_time==Inf
        v(end+1)=hdlvalidatestruct(1,...
        'The input rate of Downsample block cannot be zero or Inf.',...
        'dsp:hdl:Downsample:validateBlock:invalidrates');
    end
