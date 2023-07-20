%#codegen






function Log10ExpTable_Denormal=generateLog10ExpTable_Denormal(cfType)
    coder.allowpcode('plain');

    FractionLength=2*cfType.MantissaLength+1;
    FullLength=3+cfType.ExponentLength+FractionLength;
    Type=CustomFloatType(cfType.WordLength+cfType.MantissaLength+1,FractionLength);
    tmp=zeros(1,2^(cfType.ExponentLength)+cfType.MantissaLength);
    for ii=2:numel(tmp)
        tmp(ii)=4*log10(2)*double(ii-cfType.ExponentBias-cfType.MantissaLength-1);
    end
    tmp_cf=CustomFloat(tmp,Type);
    tmp1=bitconcat(fi(1,0,cfType.ExponentLength+3,0),tmp_cf.MantissaReal);
    tmp1(1)=0;
    tmp1(cfType.ExponentBias+cfType.MantissaLength+1)=0;

    Log10ExpTable_Denormal=reinterpretcast(tmp1,numerictype(1,FullLength,FractionLength));
    for ii=2:numel(tmp)
        if(tmp(ii)~=0)
            if(tmp(ii)<0)
                Log10ExpTable_Denormal(ii)=-Log10ExpTable_Denormal(ii);
            end
            Log10ExpTable_Denormal(ii)=bitsll(Log10ExpTable_Denormal(ii),tmp_cf.ExponentReal(ii)-Type.ExponentBias);
        end
    end
end
