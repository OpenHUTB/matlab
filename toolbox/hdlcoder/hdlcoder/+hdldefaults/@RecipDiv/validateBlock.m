function v=validateBlock(~,hC)




    v=hdlvalidatestruct;

    if targetcodegen.targetCodeGenerationUtils.isAlteraMode()&&targetmapping.hasFloatingPointPort(hC)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:mathtgtinvalidarch'));
    end

    bfp=hC.SimulinkHandle;
    sat=strcmp(get_param(bfp,'SaturateOnIntegerOverflow'),'on');
    rnd=get_param(bfp,'RndMeth');

    inputs=hC.SLInputPorts;
    ins=inputs.Signal;
    outputs=hC.SLOutputPorts;
    outs=outputs.Signal;

    intype=hdlsignalsizes(ins);
    outtype=hdlsignalsizes(outs);

    invectsize=max(hdlsignalvector(ins));
    inrecsize=1;
    inBaseType=getLeafType(ins.Type);
    if ins.Type.isRecordType
        inrecsize=numel(ins.Type.MemberTypesFlattened);
        inBaseType=ins.Type.MemberTypesFlattened(1).BaseType;
    end

    if(invectsize>1||inrecsize>1)
        hT=getPirSignalBaseType(hC.PirInputSignals.Type);
        hLeafType=hT.getLeafType;
        if isFloatType(hLeafType)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorinmathfloat'));
        else
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipvectorinmathfixed'));
        end
    end

    if(~strcmpi(rnd,'zero'))&&~strcmpi(get_param(bfp,'AlgorithmMethod'),'Newton-Raphson')
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipRnd'));
    end

    if(~sat)
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipsat'));
    end

    if((outtype(3)&&outtype(1)==0&&outtype(2)==0)||...
        (intype(3)&&intype(1)==0&&intype(2)==0))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:recipnofixpoutmath'));
    end

    outDataType=get_param(bfp,'OutDataTypeStr');



    if~isFloatType(inBaseType)
        inWL=inBaseType.WordLength;
        inFL=-inBaseType.FractionLength;
        if~strcmpi(outDataType,'Inherit: Inherit via internal rule')&&(inFL>inWL)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:UnsupportedDataTypeMathReciprocal'));
        end
    end





