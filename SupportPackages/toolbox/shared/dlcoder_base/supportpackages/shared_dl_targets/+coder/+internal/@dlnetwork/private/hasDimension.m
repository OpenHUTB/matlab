function tf=hasDimension(formatLabel,dim)











%#codegen



    coder.internal.prefer_const(formatLabel,dim);
    coder.inline('always');
    coder.allowpcode('plain');

    tf=coder.const(@feval,'contains',coder.const(formatLabel),coder.const(dim));
end
