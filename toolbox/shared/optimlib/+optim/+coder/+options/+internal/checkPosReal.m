function p=checkPosReal(v)





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(v);

    p=isnumeric(v)&&isreal(v)&&coder.internal.scalarizedAll(@(x)x>zeros('like',x),v);
end