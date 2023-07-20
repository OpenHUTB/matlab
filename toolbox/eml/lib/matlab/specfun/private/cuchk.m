function nz=cuchk(y,ascle,tol)











%#codegen

    coder.allowpcode('plain');
    yr=abs(real(y));
    yi=abs(imag(y));
    if yr>yi
        smallpart=yi;
        largepart=yr;
    else
        smallpart=yr;
        largepart=yi;
    end
    if smallpart<=ascle&&largepart<smallpart/tol
        nz=cast(1,'int32');
    else
        nz=cast(0,'int32');
    end