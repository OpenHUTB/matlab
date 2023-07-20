function[psidft,F]=amorletFilter(omega,scales,fs,dataclass)





    coder.allowpcode('plain');

%#codegen


    Ns=cast(numel(scales),'int32');
    Nomega=cast(numel(omega),'int32');
    psidft=coder.nullcopy(zeros(Ns,Nomega,dataclass));
    F=coder.nullcopy(zeros(Ns,1,dataclass));
    fc=6.0;

    FourierFactor=fc/(2*pi)*fs;
    mul=2.0;

    M=idivide(Nomega,2)+int32(1);
    coder.gpu.kernel();
    for kk=1:Ns
        for jj=1:Nomega
            if jj>M
                psidft(kk,jj)=cast(0.0,dataclass);
            else
                psidft(kk,jj)=...
                cast(mul*exp(-0.5*((scales(kk)*omega(jj)-fc)*(scales(kk)*omega(jj)-fc)))*(scales(kk)*omega(jj)>0),dataclass);
            end
            if(jj==1)
                F(kk)=cast(FourierFactor/scales(kk),dataclass);
            end
        end
    end







