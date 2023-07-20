function[psidft,F]=morseBPFilters(omega,scales,ga,be,fs,dataclass)





    coder.allowpcode('plain');

%#codegen

    fo=wavelet.internal.cwt.morsepeakfreq(ga,be);
    factor=exp(-be*log(fo)+fo^ga);

    Ns=cast(numel(scales),'int32');
    Nomega=cast(numel(omega),'int32');

    psidft=coder.nullcopy(zeros(Ns,Nomega,dataclass));
    F=coder.nullcopy(zeros(Ns,1,dataclass));


    M=idivide(Nomega,2)+int32(1);
    coder.gpu.kernel();
    for kk=1:Ns
        coder.gpu.kernel();
        for jj=1:Nomega
            if jj>M
                psidft(kk,jj)=cast(0.0,dataclass);
            else
                psidft(kk,jj)=cast(2*factor*exp(be*log(scales(kk)*omega(jj))-(scales(kk)*omega(jj))^ga),dataclass);
            end
            if(jj==1)
                F(kk)=cast((fo/scales(kk))/(2*pi)*fs,dataclass);
            end
        end
    end















