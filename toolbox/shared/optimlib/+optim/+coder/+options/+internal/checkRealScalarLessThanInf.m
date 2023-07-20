function p=checkRealScalarLessThanInf(v)





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(v);

    p=optim.coder.options.internal.checkRealScalar(v)&&v<Inf('like',v);
end