%#codegen



function Log2_E=generateLog2_E(cfType,fname)
    coder.allowpcode('plain');

    if(nargin<2)
        fname='pow10';
    end

    if strcmp(fname,'sinh')
        IntermPrec=cfType.SinhIntermediatePrec;
    elseif strcmp(fname,'tanh')
        IntermPrec=cfType.TanhIntermediatePrec;
    else
        IntermPrec=cfType.Pow10IntermediatePrec;
    end

    tmp=1/log(2);
    Type=CustomFloatType(IntermPrec+5,IntermPrec);
    tmp_cf=CustomFloat(tmp,Type);
    tmp1=bitconcat(fi(1,0,1,0),tmp_cf.MantissaReal);
    Log2_E=reinterpretcast(tmp1,numerictype(0,tmp1.WordLength,tmp1.WordLength-1));
end
