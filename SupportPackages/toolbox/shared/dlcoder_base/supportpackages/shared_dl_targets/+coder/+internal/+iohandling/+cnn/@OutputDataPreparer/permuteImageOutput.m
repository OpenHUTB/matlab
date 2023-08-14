%#codegen













function outputT=permuteImageOutput(output,targetLibrary)





    coder.inline('always');
    coder.allowpcode('plain');

    if~coder.const(@feval,'coder.internal.coderNetworkUtils.hasPermuteForTarget',targetLibrary)
        outputT=output;
    else
        if coder.isColumnMajor

            outputT=coder.internal.coderNetworkUtils.transposeHWDims(output);
        else



            outputT=permute(output,coder.const([3,4,2,1]));
        end
    end
end
