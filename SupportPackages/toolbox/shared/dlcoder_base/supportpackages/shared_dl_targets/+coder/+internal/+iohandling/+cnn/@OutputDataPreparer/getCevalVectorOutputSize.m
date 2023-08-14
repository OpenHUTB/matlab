%#codegen










function outsizeC=getCevalVectorOutputSize(outsize,targetLibrary)




    coder.inline('always');
    coder.allowpcode('plain');

    coder.internal.prefer_const(targetLibrary);

    assert(numel(outsize)==2);

    if~coder.const(@feval,'coder.internal.coderNetworkUtils.hasPermuteForTarget',targetLibrary)
        outsizeC=outsize;
    else
        if coder.isColumnMajor


            tempSize=outsize;
            tempSize(1)=outsize(2);
            tempSize(2)=outsize(1);
            outsizeC=tempSize;
        else



            outsizeC=outsize;
        end
    end
end
