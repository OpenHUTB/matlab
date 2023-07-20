







%#codegen
function outputT=permuteImageOutput(output,format)
    coder.internal.prefer_const(format);



    coder.inline('always');
    coder.allowpcode('plain');

    if coder.isColumnMajor

        outputT=coder.internal.coderNetworkUtils.transposeHWDims(output);
    else



        if hasDimension(coder.const(format),'B')

            coder.internal.assert(coder.const(numel(format))==4,'dlcoder_spkg:cnncodegen:DLCoderInternalError');
            outputT=permute(output,coder.const([3,4,2,1]));
        else

            coder.internal.assert(coder.const(numel(format))==3,'dlcoder_spkg:cnncodegen:DLCoderInternalError');
            outputT=permute(output,coder.const([2,3,1]));
        end
    end

end
