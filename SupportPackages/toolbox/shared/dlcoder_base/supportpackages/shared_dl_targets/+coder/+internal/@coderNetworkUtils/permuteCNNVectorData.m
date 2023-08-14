%#codegen









function outData=permuteCNNVectorData(inData,targetLib)




    coder.inline('always');
    coder.allowpcode('plain');

    if~coder.const(@feval,'coder.internal.coderNetworkUtils.hasPermuteForTarget',targetLib)



        outData=inData';
    else
        if coder.isColumnMajor



            outData=inData';
        else


            outData=inData;
        end
    end
end
