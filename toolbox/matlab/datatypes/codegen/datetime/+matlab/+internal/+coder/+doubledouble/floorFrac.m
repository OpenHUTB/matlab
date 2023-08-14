function[b,frac]=floorFrac(a)%#codegen








    coder.allowpcode('plain');


    B=matlab.internal.coder.doubledouble.floor(a);
    c=matlab.internal.coder.doubledouble.minus(a,B);
    b=real(B)+imag(B);
    frac=real(c)+imag(c);
end

