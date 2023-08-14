function c=times(a,b)%#codegen




    coder.allowpcode('plain');


    c=matlab.internal.coder.doubledouble.two_prod(real(a),b);
    c=matlab.internal.coder.doubledouble.addToLoAndAdjust(c,(imag(a)*b));
end
