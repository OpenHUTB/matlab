%#codegen




function LogTable=generateLogTable(cfType)
    coder.allowpcode('plain');

    tmp=zeros(1,cfType.Log2NumberOfIterations);

    for ii=1:1:numel(tmp)
        tmp(ii)=log(1+2^(-ii));
    end
    tmp_cf=CustomFloat(tmp,cfType.ExponentLength+cfType.Log2IntermediatePrec,cfType.Log2IntermediatePrec-1);
    tmp1=bitconcat(fi(1,0,3,0),tmp_cf.MantissaReal,fi(0,0,cfType.Log2NumberOfIterations,0));
    for ii=1:1:numel(tmp)
        tmp1(ii)=bitsrl(tmp1(ii),cfType.ExponentBias-tmp_cf.ExponentReal(ii));
    end
    LogTable=reinterpretcast(tmp1,numerictype(1,cfType.Log2IntermediatePrec+cfType.Log2NumberOfIterations+2,...
    cfType.Log2IntermediatePrec+cfType.Log2NumberOfIterations-1));
end
