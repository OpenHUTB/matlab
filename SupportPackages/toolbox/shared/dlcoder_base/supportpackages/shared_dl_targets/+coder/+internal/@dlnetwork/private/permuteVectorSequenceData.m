function permutedResult=permuteVectorSequenceData(outputData)







%#codegen



    coder.inline('always');
    coder.allowpcode('plain');

    if coder.isColumnMajor

        permutationDims=coder.const(1:ndims(outputData));
    else

        permutationDims=coder.const(ndims(outputData):-1:1);
    end

    permutedResult=permute(outputData,permutationDims);

end