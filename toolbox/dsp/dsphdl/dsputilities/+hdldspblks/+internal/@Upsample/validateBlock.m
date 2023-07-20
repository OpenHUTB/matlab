function[v]=validateBlock(this,hC)%#ok<INUSL>


    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;

    initialCondition=strcmpi(get_param(bfp,'ic'),'0');

    if(initialCondition)
        v(end+1)=hdlvalidatestruct(3,...
        message('dsp:hdl:Upsample:validateBlock:icnotused'));
    end



    in=hC.SLInputPorts(1).Signal;

    ip_samp_time=hdlsignalrate(in);

    if ip_samp_time==0||ip_samp_time==Inf
        v(end+1)=hdlvalidatestruct(1,...
        message('dsp:hdl:Upsample:validateBlock:invalidrates'));
    end
