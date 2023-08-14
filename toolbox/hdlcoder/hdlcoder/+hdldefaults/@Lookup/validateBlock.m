function v=validateBlock(this,hC)


    v=hdlvalidatestruct;

    in=hC.SLInputPorts(1).Signal;
    out=hC.SLOutputPorts(1).Signal;

    if max(hdlsignalvector(in))>1||max(hdlsignalvector(out))>1
        v(end+1)=hdlvalidatestruct(1,...
        'HDL code generation for vector ports are not supported for Lookup Tables block.',...
        'hdlcoder:validate:vectorports');
    end

    slbh=hC.SimulinkHandle;
    tablein=this.hdlslResolve('InputValues',slbh);
    sizes=hdlsignalsizes(in);
    wordlen=sizes(1);

    if wordlen>32
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:lookupinputlength'));
    elseif wordlen~=0&&(2^wordlen)>length(tablein)
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:inputrange'));
    end

    method=get_param(slbh,'LookUpMeth');
    obj=get_param(slbh,'object');
    possibleVals=obj.getPropAllowedValues('LookUpMeth');
    if~strcmp(method,possibleVals{3})
        v(end+1)=hdlvalidatestruct(1,...
        sprintf('The Lookup Table block only supports the ''%s'' lookup method.',possibleVals{3}),...
        'hdlcoder:validate:lookupmethod');
    end
