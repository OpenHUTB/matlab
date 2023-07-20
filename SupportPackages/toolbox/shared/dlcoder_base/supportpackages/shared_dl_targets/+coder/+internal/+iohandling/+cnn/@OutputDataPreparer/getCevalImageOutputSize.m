%#codegen










function outsizeC=getCevalImageOutputSize(outsize,targetLibrary)




    coder.inline('always');
    coder.allowpcode('plain');

    coder.internal.prefer_const(targetLibrary);

    if~coder.const(@feval,'coder.internal.coderNetworkUtils.hasPermuteForTarget',targetLibrary)
        outsizeC=outsize;
    else

        if coder.isColumnMajor
            tempSize=outsize;


            tempSize(1)=outsize(2);
            tempSize(2)=outsize(1);
            outsizeC=tempSize;

        else




            numDimsInOut=coder.const(numel(outsize));
            coder.internal.assert(numDimsInOut<=4,'dlcoder_spkg:cnncodegen:DLCoderInternalError');

            outsizeC=coder.const(outsize([numDimsInOut:-1:3,1,2]));
        end
    end
end
