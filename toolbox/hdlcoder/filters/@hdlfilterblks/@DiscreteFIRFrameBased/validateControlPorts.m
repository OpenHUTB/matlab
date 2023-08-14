function v=validateControlPorts(this,hC)




    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');

    reset_type=get_param(hC.SimulinkHandle,'ExternalReset');
    if(~strcmpi(reset_type,'None'))
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:DFIR_ExternalReset_None',reset_type,block.HDLData.archSelection));
    end

    try
        hasEnablePort=strcmpi(get_param(hC.SimulinkHandle,'ShowEnablePort'),'on');
    catch
        hasEnablePort=false;
    end

    if hasEnablePort
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:filters:validateFrameBased:DFIR_EnablePort_FrameBased',block.HDLData.archSelection));
    end
