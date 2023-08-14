







function out=realmaxLike(in)
    out=half.typecast(uint16(31743));
    if~isreal(in)
        out=complex(out);
    end
end
