







function out=epsLike(in)
    out=half.eps;
    if~isreal(in)
        out=complex(out);
    end
end