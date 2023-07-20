function v=validateBlock(this,hC)





    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;



    filter_length=this.hdlslResolve('L',bfp);
    if filter_length<2
        v(end+1)=hdlvalidatestruct(1,message('dsp:hdl:lms:LMSUnsupportedLength'));
    end

    algorithm=get_param(bfp,'Algo');
    if strcmpi(algorithm,'Normalized LMS')
        v(end+1)=hdlvalidatestruct(1,message('dsp:hdl:lms:LMSUnsupportedMode'));
    end


    inSigs=hC.SLInputSignals;
    outSigs=hC.SLOutputSignals;


    checkvectoroutput=true;
    for ii=1:2
        if hdlissignalvector(inSigs(ii))
            v(end+1)=hdlvalidatestruct(1,message('dsp:hdl:lms:LMSUnsupportedVectorInputOutput'));%#ok
            checkvectoroutput=false;
            break;
        end
    end
    if checkvectoroutput
        for ii=1:2
            if hdlissignalvector(outSigs(ii))
                v(end+1)=hdlvalidatestruct(1,message('dsp:hdl:lms:LMSUnsupportedVectorInputOutput'));%#ok
                break;
            end
        end
    end




    for ii=1:2
        if hdlsignalisdouble(inSigs(ii))
            v(end+1)=hdlvalidatestruct(1,message('dsp:hdl:lms:LMSUnsupportedInputPorts'));%#ok
            break;
        end
    end


    iport_cnt=3;

    if~strcmpi(get_param(bfp,'stepflag'),'Dialog')
        if hdlsignalisdouble(inSigs(iport_cnt))
            v(end+1)=hdlvalidatestruct(1,message('dsp:hdl:lms:LMSUnsupportedStepPorts'));
        end
        iport_cnt=iport_cnt+1;
    end




    if strcmpi(get_param(bfp,'Adapt'),'on')
        if~hdlsignalisboolean(inSigs(iport_cnt))
            v(end+1)=hdlvalidatestruct(1,message('dsp:hdl:lms:LMSUnsupportedAdaptPorts'));
        end
        iport_cnt=iport_cnt+1;
    end

    switch(get_param(bfp,'resetflag'))
    case{'None'}

    otherwise

        rstsizes=hdlsignalsizes(inSigs(iport_cnt));
        if(rstsizes(3)~=0)
            v(end+1)=hdlvalidatestruct(1,message('dsp:hdl:lms:LMSUnsupportedResetPorts'));
        end
        iport_cnt=iport_cnt+1;%#ok
    end



