function Z=callEML(X,Y,M,K,N,matrixMultiplicationParameters,activationFunction,W)




%#codegen

    coder.inline('always');
    coder.allowpcode('plain');

    if nargin<8


        W=zeros(M,1,'like',X);
    end

    [cacheBlockSizeM,cacheBlockSizeK,cacheBlockSizeN]=...
    coder.internal.layer.matrixMultiplication.getCacheBlockSizes(M,K,N,matrixMultiplicationParameters);



    if N==1

        Z=coder.nullcopy(zeros(M,1,'like',X));
        Z=coder.internal.layer.matrixMultiplication.tilingMatVecMulAdd(Z,X,Y,W,M,K,cacheBlockSizeM,...
        cacheBlockSizeK,activationFunction);
    else
        Z=coder.internal.layer.matrixMultiplication.tilingMatMulMNAdd(X,Y,W,M,N,K,cacheBlockSizeM,...
        cacheBlockSizeN,cacheBlockSizeK,activationFunction);
    end

end
