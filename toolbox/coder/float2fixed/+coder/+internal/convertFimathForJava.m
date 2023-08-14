function fmStruct=convertFimathForJava(fm)
    if isempty(fm)
        fmStruct=[];
        return;
    end

    fmStruct.RoundingMethod=fm.RoundingMethod;
    fmStruct.OverflowAction=fm.OverflowAction;

    fmStruct.ProductMode=fm.ProductMode;
    fmStruct.ProductWordLength=fm.ProductWordLength;
    fmStruct.MaxProductWordLength=fm.MaxProductWordLength;

    fmStruct.SumMode=fm.SumMode;
    fmStruct.SumWordLength=fm.SumWordLength;
    fmStruct.MaxSumWordLength=fm.MaxSumWordLength;
end