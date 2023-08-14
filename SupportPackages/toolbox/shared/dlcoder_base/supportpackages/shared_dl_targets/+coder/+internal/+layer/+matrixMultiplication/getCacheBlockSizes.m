function[cacheBlockSizeM,cacheBlockSizeK,cacheBlockSizeN]=getCacheBlockSizes(M,K,N,matrixMultiplicationParameters)


















%#codegen

    coder.allowpcode('plain');
    coder.inline('always');


    if coder.const(coder.isRowMajor)


        cacheBlockSizeM=coder.internal.layer.matrixMultiplication.setBlockSize(coder.internal.indexInt(...
        matrixMultiplicationParameters.CacheBlockSizeM),N);
        cacheBlockSizeN=coder.internal.layer.matrixMultiplication.setBlockSize(coder.internal.indexInt(...
        matrixMultiplicationParameters.CacheBlockSizeN),M);
    else
        cacheBlockSizeM=coder.internal.layer.matrixMultiplication.setBlockSize(coder.internal.indexInt(...
        matrixMultiplicationParameters.CacheBlockSizeM),M);
        cacheBlockSizeN=coder.internal.layer.matrixMultiplication.setBlockSize(coder.internal.indexInt(...
        matrixMultiplicationParameters.CacheBlockSizeN),N);
    end

    cacheBlockSizeK=coder.internal.layer.matrixMultiplication.setBlockSize(coder.internal.indexInt(...
    matrixMultiplicationParameters.CacheBlockSizeK),K);

end
