function blockSize=setBlockSize(blockSize,blockDimension)




%#codegen

    coder.allowpcode('plain');
    coder.inline('always');

    if coder.internal.isConst(blockDimension)&&blockSize>blockDimension
        blockSize=blockDimension;
    end



end
