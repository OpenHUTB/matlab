function[fifoDepth,burstSize]=getDMAParams(depth,size,mm_dw,s_dw)

    mm_dw=str2double(mm_dw);
    s_dw=str2double(s_dw);

    fifoDepth=depth;
    fifoDepth=2^nextpow2(fifoDepth);
    fifoDepth=min(max(fifoDepth,2),32);
    fifoDepth=num2str(fifoDepth);


    burstSize=ceil(size*s_dw/8);
    burstSize=2^nextpow2(burstSize);
    bsize_min=(mm_dw/8)*2;
    bsize_max=min(256*(mm_dw/8),4096);
    burstSize=max(bsize_min,burstSize);
    burstSize=min(burstSize,bsize_max);
    burstSize=num2str(burstSize);
end