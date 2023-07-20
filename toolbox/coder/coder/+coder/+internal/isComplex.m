function cplx=isComplex(x)





    if~isa(x,'coder.PrimitiveType')
        cplx=-1;
        return;
    else
        cplx=x.Complex;
    end

end
