function v=validateRegisterRates(hC)


    v=hdlvalidatestruct;

    in=hC.SLInputSignals(1);
    out=hC.SLOutputSignals(1);
    ip_samp_time=in.SimulinkRate;
    op_samp_time=out.SimulinkRate;

    bothZero=all([ip_samp_time,op_samp_time]==0);
    bothInf=all([ip_samp_time,op_samp_time]==Inf);

    anyZero=any([ip_samp_time,op_samp_time]==0);
    anyInf=any([ip_samp_time,op_samp_time]==Inf);

    if bothZero||bothInf
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:DelaySampleTimeMissing'));
    elseif~anyZero&&~anyInf
        if ip_samp_time~=op_samp_time
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:DelaySampleTimeMismatch'));
        end
    end

    if v(end).Status~=0
        gp=pir;
        if gp.streamingRequested||gp.sharingRequested
            slbh=hC.SimulinkHandle;
            st=str2double(get_param(slbh,'SampleTime'));
            if st==0
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:StreamShareContinuousRate'));
            elseif st==Inf
                v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:StreamShareInfRate'));
            end
        end
    end
end
