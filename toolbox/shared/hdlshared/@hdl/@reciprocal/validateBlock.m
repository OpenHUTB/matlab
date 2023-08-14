function v=validateBlock(~,ins,outs,sat,rnd)


    v=hdlvalidatestruct;

    complexType=outs.Type.BaseType.isComplexType;

    if~complexType
        invectsize=max(hdlsignalvector(ins));
        isFloat=isFloatType(ins.Type.BaseType);
        if(invectsize>1&&~isFloat)
            v(end+1)=hdlvalidatestruct(1,message('HDLShared:directemit:recipvectorin'));
        end

        if(~strcmpi(rnd,'zero'))
            v(end+1)=hdlvalidatestruct(1,message('HDLShared:directemit:recipRnd'));
        end

        if(~sat)
            v(end+1)=hdlvalidatestruct(1,message('HDLShared:directemit:recipsat'));
        end

        intype=hdlsignalsizes(ins);
        outtype=hdlsignalsizes(outs);

        if((outtype(3)&&outtype(1)==0&&outtype(2)==0)||...
            (intype(3)&&intype(1)==0&&intype(2)==0))
            v(end+1)=hdlvalidatestruct(1,message('HDLShared:directemit:recipnofixpout'));
        end
    end

