function scales=freqToScales(flim,vp,omegapsi,fs)





    coder.allowpcode('plain');

%#codegen



    wrange=flim.*1/fs*2*pi;
    a0=2^(1/vp);
    s0=omegapsi/wrange(2);
    smax=omegapsi/wrange(1);
    numoctaves=log2(smax/s0);
    Ns=cast(floor(vp*numoctaves),'int32')+int32(1);
    scales=coder.nullcopy(zeros(1,Ns));
    coder.gpu.kernel();
    for kk=1:Ns
        scales(kk)=s0*a0^(double(kk-1));
    end




