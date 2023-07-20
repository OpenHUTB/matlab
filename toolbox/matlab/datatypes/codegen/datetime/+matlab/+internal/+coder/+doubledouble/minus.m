function cout=minus(a,b,fullPrecision)%#codegen




    coder.allowpcode('plain');


    if nargin<3
        fullPrecision=true;
    end


    ahi=real(a);
    bhi=real(b);
    alo=imag(a);
    blo=imag(b);
    c=matlab.internal.coder.doubledouble.two_diff(ahi,bhi);
    t=matlab.internal.coder.doubledouble.two_diff(alo,blo);

    c=matlab.internal.coder.doubledouble.addToLoAndAdjust(c,real(t));
    c=matlab.internal.coder.doubledouble.addToLoAndAdjust(c,imag(t));

    coder.internal.prefer_const(fullPrecision);
    if fullPrecision
        cout=c;
    else
        cout=real(c);
    end
end


