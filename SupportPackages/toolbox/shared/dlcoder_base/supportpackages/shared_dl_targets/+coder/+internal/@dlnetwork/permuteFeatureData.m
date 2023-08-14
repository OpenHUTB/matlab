function permutedData=permuteFeatureData(~,inputData)







%#codegen



    coder.allowpcode('plain');
    coder.inline('always');


    if coder.isRowMajor




        permutedData=inputData';
    else

        permutedData=inputData;
    end

end
