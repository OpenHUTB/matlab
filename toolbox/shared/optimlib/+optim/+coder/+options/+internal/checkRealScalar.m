function p=checkRealScalar(v)





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(v);

    p=isnumeric(v)&&isreal(v)&&isscalar(v);
end