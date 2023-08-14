%#codegen



function Ln2=generateLn2(cfType,fname)
    coder.allowpcode('plain');

    if(nargin<2)
        fname='pow2';
    end

    if strcmp(fname,'pow')
        IntermPrec=cfType.PowIntermediatePow2Prec;
    elseif strcmp(fname,'sinh')
        IntermPrec=cfType.SinhIntermediatePrec;
    elseif strcmp(fname,'tanh')
        IntermPrec=cfType.TanhIntermediatePrec;
    else
        IntermPrec=cfType.Pow2IntermediatePrec;
    end

    if(IntermPrec-1>23)
        tmp=log(2);
    else
        tmp=single(log(2));
    end
    Type=CustomFloatType(cfType.WordLength+IntermPrec-cfType.MantissaLength-1,IntermPrec-1);
    tmp_cf=CustomFloat(tmp,Type);
    tmp1=bitconcat(fi(1,0,2,0),tmp_cf.MantissaReal);
    Ln2=reinterpretcast(tmp1,numerictype(0,IntermPrec+1,IntermPrec));
end
