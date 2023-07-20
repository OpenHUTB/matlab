%#codegen






function LogExpTable_Denormal=generateLogExpTable_Denormal(cfType)
    coder.allowpcode('plain');

    FractionLength=2*cfType.MantissaLength+1;
    FullLength=3+cfType.ExponentLength+FractionLength;
    Type=CustomFloatType(cfType.WordLength+cfType.MantissaLength+1,FractionLength);
    tmp=zeros(1,2^(cfType.ExponentLength)+cfType.MantissaLength);
    for ii=2:numel(tmp)
        tmp(ii)=log(2)*double(ii-cfType.ExponentBias-cfType.MantissaLength-1);
    end
    tmp_cf=CustomFloat(tmp,Type);
    tmp1=bitconcat(fi(1,0,cfType.ExponentLength+3,0),tmp_cf.MantissaReal);
    tmp1(1)=0;
    tmp1(cfType.ExponentBias+cfType.MantissaLength+1)=0;

    LogExpTable_Denormal=reinterpretcast(tmp1,numerictype(1,FullLength,FractionLength));
    for ii=2:numel(tmp)
        if(tmp(ii)~=0)
            if(tmp(ii)<0)
                LogExpTable_Denormal(ii)=-LogExpTable_Denormal(ii);
            end
            if(tmp_cf.ExponentReal(ii)<Type.ExponentBias)
                LogExpTable_Denormal(ii)=bitsra(LogExpTable_Denormal(ii),Type.ExponentBias-tmp_cf.ExponentReal(ii));
            else
                LogExpTable_Denormal(ii)=bitsll(LogExpTable_Denormal(ii),tmp_cf.ExponentReal(ii)-Type.ExponentBias);
            end
        end
    end
end
