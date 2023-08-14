function[cfs,coi]=wt(x,psidft,wavcf,wname,Fs,varargin)





    coder.allowpcode('plain');

%#codegen


    ga=3;
    be=20;
    if~isempty(varargin)
        ga=varargin{1};
        be=varargin{2};
    end

    Nfilt=cast(size(psidft,2),'int32');
    Norig=cast(numel(x),'int32');
    Npad=idivide(Nfilt-Norig,2);
    Ns=cast(size(psidft,1),'int32');
    coder.internal.assert(Npad>=0,'Wavelet:codegeneration:GPUSignalLength');


    isRealX=isreal(x);
    if~isRealX

        coder.gpu.kernel();
        for ii=1:Norig
            x(ii)=0.5*x(ii);
        end
        cfs=coder.nullcopy(complex(zeros(Ns,Norig,2,'like',x)));
        cfstmp=coder.nullcopy(complex(zeros(Ns,Nfilt,2,'like',x)));
        xv=coder.nullcopy(complex(zeros(1,Nfilt,'like',x)));
    else
        xv=coder.nullcopy(zeros(1,Nfilt,'like',x));
        cfs=coder.nullcopy(complex(zeros(Ns,Norig,'like',x)));
        cfstmp=coder.nullcopy(complex(zeros(Ns,Nfilt,'like',x)));
    end
    Npadded=cast(numel(xv),'int32');




    if Npad>0

        coder.gpu.kernel();
        for kk=1:Npadded
            if kk<(Npad+1)
                xv(kk)=x(Npad-kk+1);
            elseif kk>Npad&&kk<=Npad+Norig
                xv(kk)=x(abs(Npad-kk));
            elseif kk>Norig+Npad
                xv(kk)=x(2*Norig-kk+Npad+1);
            end
        end
    else
        coder.gpu.kernel();
        for kk=1:Norig
            xv(kk)=x(kk);
        end


    end


    if~isRealX
        cfstmp(:,:,1)=wavelet.internal.gpu.realWT(xv,psidft);
        cfstmp(:,:,2)=wavelet.internal.gpu.complexWT(xv,psidft);
    else
        cfstmp=wavelet.internal.gpu.realWT(xv,psidft);
    end


    if Npad>0
        coder.gpu.kernel();
        for ii=1:Ns
            for jj=Npad+1:Npad+Norig
                cfs(ii,jj-Npad,1)=cfstmp(ii,jj,1);
                if~isRealX
                    cfs(ii,jj-Npad,2)=cfstmp(ii,jj,2);
                end
            end
        end
    else
        coder.gpu.kernel();
        for ii=1:Ns
            for jj=Npad+1:Npad+Norig
                cfs(ii,jj,1)=cfstmp(ii,jj,1);
                if~isRealX
                    cfs(ii,jj,2)=cfstmp(ii,jj,2);
                end
            end
        end
    end


    if strcmpi(wname,'morse')
        [FourierFactor,sigmaPsi]=wavelet.internal.cwt.wavCFandSD(...
        wname,ga,be);
    else
        [FourierFactor,sigmaPsi]=wavelet.internal.cwt.wavCFandSD(...
        wname);
    end
    coiScalar=FourierFactor/sigmaPsi;

    dt=1/Fs;
    maxwavcf=max(wavcf);
    coi=cast(createCoi(Norig,coiScalar,maxwavcf,dt),'like',x);


    function coi=createCoi(N,coiScalar,maxwavcf,dt)

        coi=coder.nullcopy(zeros(N,1));
        IsOdd=rem(N,2)==1;
        M=ceil(N/2);
        coder.gpu.kernel();
        for kk=1:N
            index=int32(0);
            if kk<=M
                index=kk;
            elseif kk==M+1&&~IsOdd
                index=M;
            elseif kk>M&&IsOdd
                index=N-kk+1;
            elseif kk>M+1&&~IsOdd
                index=N-kk+1;
            end
            coi(kk)=1/(coiScalar*dt*double(index));


            if coi(kk)>maxwavcf
                coi(kk)=maxwavcf;
            end

        end











