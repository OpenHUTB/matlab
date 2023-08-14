function permutedData=permuteVectorSequenceData(~,inputData,format)








%#codegen



    coder.inline('always');
    coder.allowpcode('plain');
    coder.internal.prefer_const(format);
    nbDims=coder.const(numel(format));
    if coder.isColumnMajor

        permutationDims=coder.const(1:nbDims);
    else

        permutationDims=coder.const(nbDims:-1:1);
    end

    permutedData=permute(inputData,permutationDims);

end