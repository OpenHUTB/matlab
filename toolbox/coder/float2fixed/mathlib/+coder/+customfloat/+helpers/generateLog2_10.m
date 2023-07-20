%#codegen



function Log2_10=generateLog2_10(cfType)
    coder.allowpcode('plain');

    tmp=log2(10);
    Type=CustomFloatType(cfType.Pow10IntermediatePrec+5,cfType.Pow10IntermediatePrec);
    tmp_cf=CustomFloat(tmp,Type);
    tmp1=bitconcat(fi(1,0,1,0),tmp_cf.MantissaReal);
    Log2_10=reinterpretcast(tmp1,numerictype(0,tmp1.WordLength,tmp1.WordLength-1));
end
