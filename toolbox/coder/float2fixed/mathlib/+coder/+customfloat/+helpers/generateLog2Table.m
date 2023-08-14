%#codegen




function Log2Table=generateLog2Table(cfType,func)
    coder.allowpcode('plain');

    if strcmp(func,'log2')
        NumIter=cfType.Log2NumberOfIterations;
        IntermPrec=cfType.Log2IntermediatePrec;
        FL=IntermPrec+NumIter+2;
    elseif strcmp(func,'power_log2')
        NumIter=cfType.PowNumberOfLog2Iterations;
        IntermPrec=cfType.PowIntermediateLog2Prec;
        FL=IntermPrec+NumIter+2;
    elseif strcmp(func,'pow2')
        NumIter=cfType.Pow2NumberOfIterations;
        IntermPrec=cfType.Pow2IntermediatePrec;
        FL=IntermPrec+3;
    elseif strcmp(func,'pow10')||strcmp(func,'exp')
        NumIter=cfType.Pow10NumberOfIterations;
        IntermPrec=cfType.Pow10IntermediatePrec;
        FL=IntermPrec+3;
    elseif strcmp(func,'power_pow2')
        NumIter=cfType.PowNumberOfPow2Iterations;
        IntermPrec=cfType.PowIntermediatePow2Prec;
        FL=IntermPrec+3;
    elseif strcmp(func,'sinh')
        NumIter=cfType.SinhNumberOfIterations;
        IntermPrec=cfType.SinhIntermediatePrec;
        FL=IntermPrec+3;
    elseif strcmp(func,'tanh')
        NumIter=cfType.TanhNumberOfIterations;
        IntermPrec=cfType.TanhIntermediatePrec;
        FL=IntermPrec+3;
    end

    if(IntermPrec-1<23)
        tmp=coder.nullcopy(zeros([1,NumIter],'single'));
    else
        tmp=coder.nullcopy(zeros(1,NumIter));
    end

    for ii=1:1:numel(tmp)
        tmp(ii)=log(1+2^(-ii))/log(2);
    end

    tmp_cf=CustomFloat(tmp,cfType.ExponentLength+IntermPrec,IntermPrec-1);
    tmp1=bitconcat(fi(1,0,3,0),tmp_cf.MantissaReal,fi(0,0,FL-3-tmp_cf.MantissaLength,0));

    if strcmp(func,'log2')||strcmp(func,'power_log2')
        for ii=1:1:numel(tmp)
            tmp1(ii)=bitsrl(tmp1(ii),ii);
        end
    end

    Log2Table=reinterpretcast(tmp1,numerictype(1,FL,...
    FL-3));
end
