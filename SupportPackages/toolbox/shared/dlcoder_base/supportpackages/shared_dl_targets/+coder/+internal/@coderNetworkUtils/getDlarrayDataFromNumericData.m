function outputDlarrayData=getDlarrayDataFromNumericData(numericData,fmt)








%#codegen



    coder.internal.prefer_const(fmt);
    coder.allowpcode('plain');
    coder.inline('always');

    outputDlarrayData=cell(1,size(numericData,2));
    coder.unroll();
    for opIdx=1:size(numericData,2)
        outputDlarrayData{opIdx}=dlarray(numericData{opIdx},coder.const(fmt{opIdx}));
    end

end