function Y=getElementForExplicitLoopRnn(X,k,j,tt,inputFormat)





%#codegen
    coder.inline('always')
    coder.allowpcode('plain')
    coder.internal.prefer_const(inputFormat)

    if~coder.internal.layer.utils.hasBatchDim(inputFormat)

        Y=X(k,tt);
    else
        Y=X(k,j,tt);
    end

end

