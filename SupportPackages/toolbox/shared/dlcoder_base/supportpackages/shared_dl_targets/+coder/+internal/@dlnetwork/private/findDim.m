function dimIdx=findDim(formatLabel,dim)










%#codegen



    coder.internal.prefer_const(formatLabel,dim);
    coder.inline('always');
    coder.allowpcode('plain');

    dimIdx=coder.const(@feval,'strfind',coder.const(formatLabel),coder.const(dim));
end
