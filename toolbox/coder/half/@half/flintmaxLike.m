







function out=flintmaxLike(in)
    out=half.typecast(uint16(26624));
    if~isreal(in)
        out=complex(out);
    end
end
