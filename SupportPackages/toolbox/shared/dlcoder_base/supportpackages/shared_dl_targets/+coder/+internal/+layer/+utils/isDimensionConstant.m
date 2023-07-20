function isConst=isDimensionConstant(inputData,inputDataFormat,fmt)






%#codegen
    coder.inline('always')
    coder.allowpcode('plain')
    coder.internal.prefer_const(inputDataFormat,fmt)

    fmtDim=coder.const(@feval,'strfind',inputDataFormat,fmt);

    if coder.const(isempty(fmtDim))
        isConst=true;
    else
        isConst=coder.internal.isConst(size(inputData,fmtDim));
    end
end
