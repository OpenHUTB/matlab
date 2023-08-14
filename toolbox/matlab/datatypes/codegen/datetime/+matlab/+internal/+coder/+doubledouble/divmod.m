function[c,rem]=divmod(a,b)%#codegen






    coder.allowpcode('plain');


    coder.internal.errorIf(b<=0,'MATLAB:datetime:DoubleDoubleAssertionCodegen')


    r=matlab.internal.coder.doubledouble.floor(matlab.internal.coder.doubledouble.divide(a,b));
    rem=real(r)+imag(r);
    c=matlab.internal.coder.doubledouble.minus(a,matlab.internal.coder.doubledouble.times(r,b));
