function p=checkLogicalScalar(v)





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(v);

    p=isscalar(v)&&islogical(v);
end