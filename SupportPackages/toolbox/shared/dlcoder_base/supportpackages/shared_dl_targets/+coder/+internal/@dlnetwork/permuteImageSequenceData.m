function permutedData=permuteImageSequenceData(~,dataInput,isDataOutput,dataFormat)











%#codegen



    coder.inline('always');
    coder.allowpcode('plain');
    coder.internal.prefer_const(isDataOutput,dataFormat);

    nbDims=coder.const(numel(dataFormat));
    if coder.isColumnMajor





        permutationDims=coder.const([2,1,3:nbDims]);

    else

        if coder.const(isDataOutput)














            permutationDims=coder.const([(nbDims-1),nbDims,(nbDims-2):-1:1]);

        else



            permutationDims=coder.const([nbDims:-1:3,1,2]);


        end
    end

    permutedData=permute(dataInput,permutationDims);

end
