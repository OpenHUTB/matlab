%#codegen







function obj=generateInvTrigFcnLookupTableNeg(func,start)

    coder.allowpcode('plain');

    if strcmp(func,'acos')
        start_uint=half(start).storedInteger;
        table_length=half(-1).storedInteger-start_uint;
        obj=coder.nullcopy(fi(zeros(table_length,1),0,10,0));
        for i=1:table_length
            acos_output=storedInteger(half(acos(single(emlhalf.typecast(uint16(start_uint+i-1))))));
            acos_fi=fi(acos_output,0,16,0);
            obj(i)=bitsliceget(acos_fi,acos_fi.WordLength-6);
        end
    end
end
