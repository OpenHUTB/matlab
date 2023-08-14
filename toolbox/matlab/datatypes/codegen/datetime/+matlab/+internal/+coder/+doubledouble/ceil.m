function dd=ceil(a)




    coder.allowpcode('plain');


    ahi=real(a);
    alo=imag(a);
    dd=ceil(ahi);
    mask=(real(dd)==ahi);
    ceil_alo=ceil(alo);
    dd(mask)=matlab.internal.coder.doubledouble....
    addToLoAndAdjust(dd(mask),ceil_alo(mask));
end
