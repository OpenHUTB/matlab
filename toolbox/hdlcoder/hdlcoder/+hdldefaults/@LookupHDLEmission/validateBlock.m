function v=validateBlock(this,hC)



    v=hdlvalidatestruct(2,message('hdlcoder:validate:LookupBlockDeprecated'));

    in=hC.SLInputPorts(1).Signal;
    out=hC.SLOutputPorts(1).Signal;

    if max(hdlsignalvector(in))>1||max(hdlsignalvector(out))>1
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:vectorports'));
    end

    bfp=hC.SimulinkHandle;
    tablein=this.hdlslResolve('InputValues',bfp);
    sizes=hdlsignalsizes(in);
    wordlen=sizes(1);

    if wordlen~=0&&(2^wordlen)>length(tablein)
        v(end+1)=hdlvalidatestruct(2,message('hdlcoder:validate:inputrange'));
    end

    method=get_param(bfp,'LookUpMeth');
    obj=get_param(bfp,'object');
    possibleVals=obj.getPropAllowedValues('LookUpMeth');
    if~strcmp(method,possibleVals{3})
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:lookupmethod',possibleVals{3}));
    end
end
