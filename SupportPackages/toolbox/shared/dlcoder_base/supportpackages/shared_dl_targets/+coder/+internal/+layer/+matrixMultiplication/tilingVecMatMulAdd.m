function Z=tilingVecMatMulAdd(Z,X,Y,W,N,K,blockSizeN,blockSizeK,activationFunction,...
    startIndexM,computeEdge)
%#codegen



    coder.allowpcode('plain');

    if nargin<11
        computeEdge=true;
    end

    if nargin<10
        startIndexM=1;
    end

    blockElemIndicesN=coder.internal.indexInt(1:blockSizeN);

    nBlock=coder.internal.indexInt(0);
    while nBlock<=N-blockSizeN
        Z=microKernel(Z,X,Y,W,blockSizeN,blockElemIndicesN,nBlock,startIndexM,K,...
        blockSizeK,activationFunction);
        nBlock=nBlock+blockSizeN;
    end

    if coder.const(computeEdge)

        blockElemIndicesN=1;
        for nElem=nBlock:N-1
            Z=microKernel(Z,X,Y,W,1,blockElemIndicesN,nElem,startIndexM,K,...
            blockSizeK,activationFunction);
        end
    end

end


function Z=microKernel(Z,X,Y,W,blockSizeN,blockElemIndicesN,nBlock,startIndexM,K,...
    blockSizeK,activationFunction)

    c=coder.nullcopy(zeros(1,blockSizeN,'like',X));
    a=coder.nullcopy(zeros(1,blockSizeK,'like',X));

    if coder.const(coder.const(size(W,2))==1)
        w=W(startIndexM,1);

        coder.unroll();
        for nElem=blockElemIndicesN
            c(nElem)=w;
        end
    else
        coder.unroll();
        for nElem=blockElemIndicesN
            c(nElem)=W(startIndexM,nBlock+nElem);
        end
    end

    kBlock=coder.internal.indexInt(0);
    while kBlock<=K-blockSizeK
        coder.unroll();
        for kElem=1:blockSizeK
            a(kElem)=X(startIndexM,kBlock+kElem);
        end

        coder.unroll();
        for nElem=blockElemIndicesN
            coder.unroll();
            for kElem=1:blockSizeK
                c(nElem)=c(nElem)+a(kElem)*Y(kBlock+kElem,nBlock+nElem);
            end
        end

        kBlock=kBlock+blockSizeK;
    end

    for kElem=kBlock+1:K
        coder.unroll();
        for nElem=blockElemIndicesN
            c(nElem)=c(nElem)+X(startIndexM,kElem)*Y(kElem,nBlock+nElem);
        end
    end

    coder.unroll();
    for nElem=blockElemIndicesN
        Z(startIndexM,nBlock+nElem)=activationFunction(c(nElem));
    end

end
