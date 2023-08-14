function v=validateBlock(this,hC)






    ports=this.getAllSLInputPorts(hC);


    ports=[ports,this.getAllSLOutputPorts(hC)];


    v=this.baseValidatePortDatatypes(ports);
    blockInfo=this.getBlockInfo(hC);

    rnd=blockInfo.rndMode;





    in1signal=hC.PirInputSignals(1);
    outsignal=hC.PirOutputSignals(1);
    in1BaseType=getPirSignalBaseType(in1signal.Type);
    outBaseType=getPirSignalBaseType(outsignal.Type);

    if in1signal.Type.isRecordType
        invectsize=numel(in1signal.Type.MemberTypesFlattened);
    else
        invectsize=max(hdlsignalvector(in1signal));
    end

    bfp=hC.SimulinkHandle;

    if(in1BaseType.isFloatType||outBaseType.isFloatType)
        isPortTypeFloat=true;
    else
        isPortTypeFloat=false;
    end

    if(in1BaseType.isComplexType||outBaseType.isComplexType)
        isPortTypeComplex=true;
    else
        isPortTypeComplex=false;
    end

    if(isPortTypeFloat)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:recipnofixpoutmath'));
        return;
    end
    if(isPortTypeComplex)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:produnsupportedcomplexdivide'));
        return;
    end

    if(~strcmpi(rnd,'zero'))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipRnd'));
    end

    if(~strcmp(get_param(bfp,'SaturateOnIntegerOverflow'),'on'))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipsat'));
    end

    if(invectsize>1)
        if(in1signal.Type.isRecordType)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipBus'));
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorinmathfixed'));
        end
    end

    WL=in1BaseType.Wordlength;

    if(WL>63)
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:makehdl:unsupportedwordlengthShiftAddMathRecip',WL,hC.Name));
    else
        if(blockInfo.numeratorTypeInfo.zWL>63)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:wordlengthOverflowDivideReciprocal'));
        end
    end
    outputWordlength=outBaseType.Wordlength;

    iterNum=outputWordlength;
    if(strcmpi(blockInfo.latencyStrategy,'CUSTOM'))
        totalPipelinestages=iterNum+4;
        if(blockInfo.customLatency>totalPipelinestages)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:fixedpointAddShiftCustomLatencyError',num2str(blockInfo.customLatency),hC.Name,num2str(totalPipelinestages),num2str(outputWordlength)));
        end
    end
end





