







function out=realminLike(in)
    out=half.typecast(uint16(1024));
    if~isreal(in)
        out=complex(out);
    end
end
