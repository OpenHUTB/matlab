function[fmtSize,fmtDim]=getFormatSizeAndDimension(inputData,inputDataFormat,fmt)





%#codegen
    coder.inline('always')
    coder.allowpcode('plain')
    coder.internal.prefer_const(inputDataFormat,fmt)

    fmtDim=coder.const(@feval,'strfind',inputDataFormat,fmt);

    if coder.const(isempty(fmtDim))
        fmtSize=1;
    else
        fmtSize=size(inputData,fmtDim);
    end

end
