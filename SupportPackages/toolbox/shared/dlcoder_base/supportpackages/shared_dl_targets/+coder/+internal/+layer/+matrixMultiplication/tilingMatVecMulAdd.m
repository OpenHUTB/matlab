function Z=tilingMatVecMulAdd(Z,X,Y,W,M,K,blockSizeM,blockSizeK,activationFunction,startIndexN,computeEdge)




%#codegen

    coder.allowpcode('plain');

    if nargin<11
        computeEdge=true;
    end

    if nargin<10
        startIndexN=1;
    end

    blockElemIndicesM=coder.internal.indexInt(1:blockSizeM);

    mBlock=coder.internal.indexInt(0);
    while mBlock<=M-blockSizeM
        Z=microKernel(Z,X,Y,W,blockSizeM,blockElemIndicesM,mBlock,startIndexN,K,...
        blockSizeK,activationFunction);
        mBlock=mBlock+blockSizeM;
    end

    if coder.const(computeEdge)

        blockElemIndicesM=1;
        for mElem=mBlock:M-1
            Z=microKernel(Z,X,Y,W,1,blockElemIndicesM,mElem,startIndexN,K,blockSizeK,...
            activationFunction);
        end
    end

end


function Z=microKernel(Z,X,Y,W,blockSizeM,blockElemIndicesM,mBlock,startIndexN,K,...
    blockSizeK,activationFunction)

    c=coder.nullcopy(zeros(blockSizeM,1,'like',X));
    b=coder.nullcopy(zeros(blockSizeK,1,'like',X));

    coder.unroll();
    for mElem=blockElemIndicesM
        c(mElem)=W(mBlock+mElem,1);
    end

    kBlock=coder.internal.indexInt(0);

    while kBlock<=K-blockSizeK
        coder.unroll();
        for kElem=coder.internal.indexInt(1:blockSizeK)
            b(kElem)=Y(kBlock+kElem,startIndexN);
        end

        coder.unroll();
        for mElem=blockElemIndicesM
            for kElem=coder.internal.indexInt(1:blockSizeK)
                c(mElem)=c(mElem)+X(mBlock+mElem,kBlock+kElem)*b(kElem);
            end
        end
        kBlock=kBlock+blockSizeK;
    end

    for kElem=kBlock+1:K
        y=Y(kElem,startIndexN);
        coder.unroll();
        for mElem=blockElemIndicesM
            c(mElem)=c(mElem)+X(mBlock+mElem,kElem)*y;
        end
    end

    coder.unroll();
    for mElem=blockElemIndicesM
        Z(mBlock+mElem,startIndexN)=activationFunction(c(mElem));
    end

end
