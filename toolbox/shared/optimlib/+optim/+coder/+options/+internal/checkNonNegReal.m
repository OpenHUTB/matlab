function p=checkNonNegReal(v,str)





%#codegen

    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(v);

    if nargin==2&&coder.internal.isCharOrScalarString(v)
        coder.internal.prefer_const(str);
        p=strcmp(v,str);
    else
        p=optim.coder.options.internal.checkRealScalar(v)&&v>=zeros('like',v);
    end

end