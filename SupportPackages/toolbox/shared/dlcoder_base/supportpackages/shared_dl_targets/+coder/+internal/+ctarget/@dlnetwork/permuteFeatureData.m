function permutedData=permuteFeatureData(~,inputData)







%#codegen



    coder.allowpcode('plain');
    coder.inline('always');


    permutedData=coder.internal.coderNetworkUtils.prepareVectorDataCcode(inputData);
end

