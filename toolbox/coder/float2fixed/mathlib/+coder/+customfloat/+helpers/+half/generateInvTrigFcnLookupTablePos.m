%#codegen








function obj=generateInvTrigFcnLookupTablePos(func,start)

    coder.allowpcode('plain');

    if strcmp(func,'asin')
        start_uint=half(start).storedInteger;
        table_length=half(1).storedInteger-start_uint;
        obj=coder.nullcopy(fi(zeros(table_length,1),0,10,0));
        for i=1:table_length
            asin_output=storedInteger(half(asin(single(half.typecast(uint16(start_uint+i-1))))));
            asin_fi=fi(asin_output,0,16,0);
            obj(i)=bitsliceget(asin_fi,asin_fi.WordLength-6);
        end
    elseif strcmp(func,'acos')
        start_uint=half(start).storedInteger;
        table_length=half(1).storedInteger-start_uint;
        obj=coder.nullcopy(fi(zeros(table_length,1),0,15,0));
        for i=1:table_length
            acos_output=storedInteger(half(acos(single(half.typecast(uint16(start_uint+i-1))))));
            acos_fi=fi(acos_output,0,16,0);
            obj(i)=bitsliceget(acos_fi,acos_fi.WordLength-1);
        end
    end
end
