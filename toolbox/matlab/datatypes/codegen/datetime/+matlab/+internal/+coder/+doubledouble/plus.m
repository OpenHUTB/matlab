function c=plus(a,b)%#codegen




    coder.allowpcode('plain');


    ahi=real(a);
    bhi=real(b);
    alo=imag(a);
    blo=imag(b);
    c=matlab.internal.coder.doubledouble.two_sum(ahi,bhi);
    t=matlab.internal.coder.doubledouble.two_sum(alo,blo);

    c=matlab.internal.coder.doubledouble.addToLoAndAdjust(c,real(t));
    c=matlab.internal.coder.doubledouble.addToLoAndAdjust(c,imag(t));
end


