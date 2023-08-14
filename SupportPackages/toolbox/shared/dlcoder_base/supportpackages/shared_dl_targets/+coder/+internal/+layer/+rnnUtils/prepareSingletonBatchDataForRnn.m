function Z=prepareSingletonBatchDataForRnn(X,inputFormat)




%#codegen
    coder.inline('always')
    coder.allowpcode('plain')
    coder.internal.prefer_const(inputFormat)


    B=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'B');
    assert(B==1,'Expected batch size to be 1');


    C=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'C');

    T=coder.internal.layer.utils.getFormatSizeAndDimension(X,inputFormat,'T');


    Z=reshape(X,C,T);

end