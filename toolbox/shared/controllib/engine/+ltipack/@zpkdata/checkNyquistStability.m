function isStable=checkNyquistStability(DL,LoopSign,varargin)





    z=DL.z{1};
    p=DL.p{1};
    k=DL.k*(-LoopSign);
    Ts=DL.Ts;
    iod=DL.Delay.Input+DL.Delay.Output+DL.Delay.IO;
    if Ts>0
        iod=Ts*iod;
    end




    if Ts==0
        Pns=sum(real(p)>0);
        m0=sum(z==0)-sum(p==0);
        minf=length(p)-length(z);
        sgnInf=-1;
    else

        Pns=sum(abs(p)>1)+max(0,length(z)-length(p));
        m0=sum(z==1)-sum(p==1);
        minf=sum(z==-1)-sum(p==-1);
        sgnInf=1;
    end


    w=freqgrid({z},{p},Ts,1);
    w=[0;w(w>0)];
    [magOL,phOL]=zpkboderesp(z,p,k,Ts,w,true);
    magOL(~isfinite(magOL))=Inf;
    if iod>0
        phOL=phOL-w*iod;
    end


    r=Pns;
    if(m0<0)||(m0==0&&magOL(1)>1)
        r=r+round(phOL(1)/pi-m0/2);
    end
    if magOL(end)>1
        r=r-round(phOL(end)/pi-sgnInf*minf/2);
    end


    inBW=(magOL>=1);
    idxc=find(xor(inBW(1:end-1),inBW(2:end)));
    if isempty(idxc)

        muS=0;
    else
        t=-log(magOL(idxc))./log(magOL(idxc+1)./magOL(idxc));

        phWC=(1-t).*phOL(idxc)+t.*phOL(idxc+1);
        wphWC=mod(phWC+pi,2*pi)-pi;
        muWC=round((phWC-wphWC)/pi);
        if magOL(1)<1
            muS=sum(muWC(2:2:end))-sum(muWC(1:2:end));
        else
            muS=sum(muWC(1:2:end))-sum(muWC(2:2:end));
        end
    end
    isStable=(muS==r);
