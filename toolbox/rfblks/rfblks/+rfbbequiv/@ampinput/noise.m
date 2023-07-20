function[cmatrix,ctype]=noise(h,freq)









    m=length(freq);
    cmatrix(1:2,1:2,1:m)=0;
    ctype='ABCD CORRELATION MATRIX';