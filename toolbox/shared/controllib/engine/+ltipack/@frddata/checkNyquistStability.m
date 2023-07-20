function isStable=checkNyquistStability(DL,LoopSign,Pns)



    w=DL.Frequency;
    h=DL.Response(:);
    Ts=DL.Ts;
    iod=DL.Delay.Input+DL.Delay.Output+DL.Delay.IO;
    if Ts==0
        inRange=(w>0&w<Inf);
    else
        iod=Ts*iod;
        inRange=(w>0&w<=pi/Ts);
    end
    w=w(inRange);
    h=(-LoopSign)*h(inRange);
    magOL=abs(h);
    phOL=unwrap(angle(h));

    if iod>0
        phOL=phOL-w*iod;
    end


    m0=round(log(magOL(2)/magOL(1))/log(w(2)/w(1)));


    offset=(2*pi)*round((phOL(1)-m0*pi/2)/(2*pi));
    phOL=phOL-offset;


    r=Pns;
    if(m0<0)||(m0==0&&magOL(1)>1)
        r=r+round(phOL(1)/pi-m0/2);
    end
    if magOL(end)>1

        isStable=false;
        return
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