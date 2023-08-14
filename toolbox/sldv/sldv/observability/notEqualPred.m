function out=notEqualPred(in1,in2)

    coder.inline('always');
    coder.allowpcode('plain');

    isIn1Fi=isfi(in1);
    isIn2Fi=isfi(in2);

    if isIn1Fi&&isIn2Fi
        out=in1~=in2;
    elseif isIn1Fi&&~isIn2Fi
        l=cast(in1,'like',in2);
        out=l~=in2;
    elseif~isIn1Fi&&isIn2Fi
        l=cast(in2,'like',in1);
        out=l~=in1;
    else
        out=in1~=in2;
    end
end

