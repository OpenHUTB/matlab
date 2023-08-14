%#codegen



function Log2E=generateLog2E(cfType,fname)
    coder.allowpcode('plain');

    if(nargin<2)
        fname='log2';
    end

    if strcmp(fname,'pow')
        ML=cfType.WordLength;
        WL=ML+cfType.ExponentLength;
    else
        ML=cfType.MantissaLength+2;
        WL=ML+cfType.ExponentLength;
    end

    if(ML>23)
        tmp=1/log(2);
    else
        tmp=single(1/(log(2)));
    end
    Type=CustomFloatType(WL,ML);
    tmp_cf=CustomFloat(tmp,Type);
    tmp1=bitconcat(fi(1,0,1,0),tmp_cf.MantissaReal);
    Log2E=reinterpretcast(tmp1,numerictype(0,ML+1,ML));
end
