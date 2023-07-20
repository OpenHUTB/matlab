function WB=TimeDomainWB(WB)













    WB.YcPls=transpose(WB.YcPls(1,:));
    WB.alfaYc=(1+WB.YcPls*WB.Ts/2)./(1-WB.YcPls*WB.Ts/2);
    lambYc=(WB.Ts/2)./(1-WB.YcPls*WB.Ts/2);
    zdum=(WB.alfaYc+1).*lambYc;
    WB.YcRes=reshape(WB.YcRes,[WB.NYc_res,1]);
    WB.CmodYc=zeros(WB.NYc_res,1);
    cont=0;
    for ii=1:WB.NYc
        WB.CmodYc(1+cont:WB.Nc*WB.Nc+cont)=WB.YcRes(1+cont:WB.Nc*WB.Nc+cont)*zdum(ii);

        cont=cont+WB.Nc*WB.Nc;
    end




    WB.GYc=zeros(WB.Nc*WB.Nc,1);
    for ii=1:WB.Nc*WB.Nc
        GYc1=WB.YcRes(ii:WB.Nc*WB.Nc:WB.Nc*WB.Nc*WB.NYc);
        zdum=real(GYc1.*lambYc);
        WB.GYc(ii)=sum(zdum);
    end
    WB.YcstD=reshape(WB.YcstD,[WB.Nc*WB.Nc,1]);
    WB.GYc=WB.GYc+WB.YcstD;





    Hpls1=zeros(sum(WB.NH),1);
    cont=0;
    for ii=1:WB.Ng
        Hpls1(cont+1:cont+WB.NH(ii))=WB.Hpls(ii,1:WB.NH(ii));
        cont=cont+WB.NH(ii);
    end
    WB.Hpls=Hpls1;
    WB.alfaH=(1+WB.Hpls*WB.Ts/2)./(1-WB.Hpls*WB.Ts/2);
    lambH=(WB.Ts/2)./(1-WB.Hpls*WB.Ts/2);
    zdum=(WB.alfaH+1).*lambH;
    HRes1=zeros(WB.NH_res,1);
    cont=0;
    for ii=1:WB.Ng
        for jj=1:WB.NH(ii)
            HRes1(1+cont:WB.Nc*WB.Nc+cont)=reshape(WB.HRes(:,:,ii,jj),[WB.Nc*WB.Nc,1]);
            cont=cont+WB.Nc*WB.Nc;
        end
    end
    WB.HRes=HRes1;
    WB.CmodH=zeros(WB.NH_res,1);
    cont=0;
    for ii=1:sum(WB.NH)
        WB.CmodH(1+cont:WB.Nc*WB.Nc+cont)=WB.HRes(1+cont:WB.Nc*WB.Nc+cont)*zdum(ii);

        cont=cont+WB.Nc*WB.Nc;
    end
    WB.GH=zeros(WB.Ng*WB.Nc*WB.Nc,1);
    cont=0;
    cont2=0;
    cont3=0;
    for jj=1:WB.Ng
        Hres=WB.HRes(1+cont:WB.Nc*WB.Nc*WB.NH(jj)+cont);
        lamb_H=lambH(1+cont2:WB.NH(jj)+cont2);
        for ii=1:WB.Nc*WB.Nc
            GH1=Hres(ii:WB.Nc*WB.Nc:WB.Nc*WB.Nc*WB.NH(jj)).*lamb_H;
            WB.GH(1+cont3)=sum(GH1);
            cont3=cont3+1;
        end
        cont=cont+WB.Nc*WB.Nc*WB.NH(jj);
        cont2=cont2+WB.NH(jj);
    end
    WB.tauj=floor(WB.tau/WB.Ts);
    WB.epsarr=WB.tau/WB.Ts-floor(WB.tau/WB.Ts);
    if any(WB.tauj<1)
        dum=find(WB.tauj<1);
        WB.tauj(dum)=1;
        WB.epsarr(dum)=0;
    end