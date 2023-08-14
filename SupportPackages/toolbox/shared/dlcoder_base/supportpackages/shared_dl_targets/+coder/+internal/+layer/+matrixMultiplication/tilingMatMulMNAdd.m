function Z=tilingMatMulMNAdd(X,Y,W,M,N,K,blockSizeM,blockSizeN,blockSizeK,activationFunction)




%#codegen

    coder.allowpcode('plain');

    Z=coder.nullcopy(zeros(M,N,'like',X));




    mStartIndex=coder.internal.indexInt(0);
    nStartIndex=coder.internal.indexInt(0);
    while mStartIndex<=M-blockSizeM
        [Z,nStartIndex]=microKernel(Z,X,Y,W,N,K,mStartIndex,blockSizeM,blockSizeN,...
        activationFunction);
        mStartIndex=mStartIndex+blockSizeM;
    end

    if nStartIndex==0


        mStartIndex=coder.internal.indexInt(0);
    end


    for mElem=mStartIndex+1:M
        Z=coder.internal.layer.matrixMultiplication.tilingVecMatMulAdd(Z,X,Y,W,N,K,blockSizeN,blockSizeK,...
        activationFunction,mElem);
    end


    computeEdge=false;
    for nElem=nStartIndex+1:N
        Z=coder.internal.layer.matrixMultiplication.tilingMatVecMulAdd(Z,X,Y,W,M,K,blockSizeM,blockSizeK,...
        activationFunction,nElem,computeEdge);
    end

end

function[Z,nStartIndex]=microKernel(Z,X,Y,W,N,K,mBlock,blockSizeM,blockSizeN,...
    activationFunction)

    c=coder.nullcopy(zeros(blockSizeM,blockSizeN,'like',X));
    a=coder.nullcopy(zeros(blockSizeM,1,'like',X));
    b=coder.nullcopy(zeros(1,blockSizeN,'like',X));

    nStartIndex=coder.internal.indexInt(0);
    while nStartIndex<=N-blockSizeN

...
...
...
...
...
...
...
...
...
...
...

        if coder.const(size(W,2)==1)





            coder.unroll();
            for mBlockElem=1:blockSizeM
                a(mBlockElem)=W(mBlock+mBlockElem,1);
            end

            coder.unroll();
            for nBlockElem=1:blockSizeN
                coder.unroll();
                for mBlockElem=1:blockSizeM
                    c(mBlockElem,nBlockElem)=a(mBlockElem);
                end
            end
        else
            for nBlockElem=1:blockSizeN
                coder.unroll();
                for mBlockElem=1:blockSizeM
                    c(mBlockElem,nBlockElem)=W(mBlock+mBlockElem,nStartIndex+nBlockElem);
                end
            end
        end

        for k=1:K

...
...
...
...
...
...

            coder.unroll();
            for mBlockElem=1:blockSizeM
                a(mBlockElem)=X(mBlock+mBlockElem,k);
            end

            coder.unroll();
            for nBlockElem=1:blockSizeN
                b(nBlockElem)=Y(k,nStartIndex+nBlockElem);
            end

...
...
...
...
...
...

            coder.unroll();
            for nBlockElem=1:blockSizeN
                coder.unroll();
                for mBlockElem=1:blockSizeM
                    c(mBlockElem,nBlockElem)=c(mBlockElem,nBlockElem)+...
                    a(mBlockElem)*b(nBlockElem);
                end
            end
        end

...
...
...
...
...
...

        coder.unroll();
        for nBlockElem=1:blockSizeN
            for mBlockElem=1:blockSizeM
                Z(mBlock+mBlockElem,nStartIndex+nBlockElem)=activationFunction(c(mBlockElem,nBlockElem));
            end
        end

        nStartIndex=nStartIndex+blockSizeN;
    end

end
