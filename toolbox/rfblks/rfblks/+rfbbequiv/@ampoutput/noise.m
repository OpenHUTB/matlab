function[cmatrix,ctype]=noise(h,freq)









    if isa(h.OriginalCkt,'rfckt.rfckt')
        [cmatrix,ctype]=noise(h.OriginalCkt,freq);
    else
        m=length(freq);
        cmatrix(1:2,1:2,1:m)=0;
        ctype='ABCD CORRELATION MATRIX';
    end