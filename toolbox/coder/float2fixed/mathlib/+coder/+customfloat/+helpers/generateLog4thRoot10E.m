%#codegen









function Log4thRoot10E=generateLog4thRoot10E(cfType)
    coder.allowpcode('plain');

    tmp=1/log(10);
    Type=CustomFloatType(cfType.WordLength+cfType.MantissaLength+1,2*cfType.MantissaLength+1);
    tmp_cf=CustomFloat(tmp,Type);
    tmp1=bitconcat(fi(1,0,1,0),tmp_cf.MantissaReal);
    Log4thRoot10E=reinterpretcast(tmp1,numerictype(0,2*cfType.MantissaLength+2,2*cfType.MantissaLength+1));
end
