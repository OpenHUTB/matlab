








function out=ctranspose(a)
    if isreal(a)
        out=transpose(a);
    else
        out=conj(transpose(a));
    end
end
