function[y1,y2,y3,y4,y5,nharmo]=initdistline(SPS,blknum)















    j=sqrt(-1);
    nphase=SPS.distline(blknum,1);
    noinp=SPS.distline(blknum,2);
    noout=SPS.distline(blknum,3);
    long=SPS.distline(blknum,4);
    icol=5;
    Zmode=SPS.distline(blknum,icol:icol+nphase-1);
    icol=icol+nphase;
    Rmode=SPS.distline(blknum,icol:icol+nphase-1);
    icol=icol+nphase;
    Smode=SPS.distline(blknum,icol:icol+nphase-1);
    t0max=long/min(Smode);
    Ts=SPS.PowerguiInfo.Ts;
    V1=[0;0;0];
    V2=[0;0;0];
    I1=[0;0;0];
    I2=[0;0;0];
    nharmo=size(SPS.yss,2);

    if any(isnan(SPS.yss))
        SPS.yss=zeros(size(SPS.yss));
    end

    if SPS.PowerguiInfo.Discrete




        tvec=[-Ts*ceil(t0max/Ts):Ts:-Ts];


        t0mode=zeros(1,nphase);
    else



        tvec=(0:t0max/5:t0max);

        t0mode=long./Smode;
    end

    n_time=length(tvec);
    icol=icol+nphase;
    Ti=reshape(SPS.distline(blknum,icol:icol+nphase^2-1),nphase,nphase);
    n1=nphase+1;n2=2*nphase;
    TTi=zeros(n2,n2);

    TTi(1:nphase,1:nphase)=Ti;TTi(n1:n2,n1:n2)=Ti;
    Vlinet=zeros(2*nphase,n_time);
    Ilinet=zeros(2*nphase,n_time);

    for ifreq=1:size(SPS.yss,2)

        w=2*pi*SPS.freq(ifreq);

        if w==0
            DC=pi/2;
        else
            DC=0;
        end









        Vmode=TTi'*SPS.yss(noout:noout+2*nphase-1,ifreq);
        Vline=Vmode.*exp(-j*w*[t0mode,t0mode]');
        if w==0,
            Vlinet=Vlinet+real(Vline*exp(j*w*tvec));
        else
            Vlinet=Vlinet+imag(Vline*exp(j*w*tvec));
        end





        [H2]=etahlin(size(SPS.D,2),size(SPS.yss,1),SPS.freq(ifreq),SPS);
        u2=H2*SPS.yss(:,ifreq);
        h=(Zmode-Rmode*long/4)./(Zmode+Rmode*long/4);
        Imode=inv(TTi)*u2(noinp:noinp+2*nphase-1);
        Iline=Imode.*[h,h]'.*exp(-j*w*[t0mode,t0mode]');

        if w==0
            Ilinet=Ilinet+real(Iline*exp(j*w*tvec));
        else
            Ilinet=Ilinet+imag(Iline*exp(j*w*tvec));
        end

        V1=[
        V1(1,:),abs(Vline(1:nphase))';
        V1(2,:),ones(1,nphase)*w;
        V1(3,:),(angle(Vline(1:nphase))'+DC);
        ];

        V2=[
        V2(1,:),abs(Vline(nphase+1:2*nphase))';
        V2(2,:),ones(1,nphase)*w;
        V2(3,:),(angle(Vline(nphase+1:2*nphase))'+DC);
        ];

        I1=[
        I1(1,:),abs(Iline(1:nphase))';
        I1(2,:),ones(1,nphase)*w;
        I1(3,:),(angle(Iline(1:nphase))'+DC);
        ];

        I2=[
        I2(1,:),abs(Iline(nphase+1:2*nphase))';
        I2(2,:),ones(1,nphase)*w;
        I2(3,:),(angle(Iline(nphase+1:2*nphase))'+DC);
        ];

    end


    V1=V1(:,2:end);
    V2=V2(:,2:end);
    I1=I1(:,2:end);
    I2=I2(:,2:end);


    y1=[tvec',Vlinet(1:nphase,:)'];
    y2=[tvec',Vlinet(nphase+1:2*nphase,:)'];
    y3=[tvec',Ilinet(1:nphase,:)'];
    y4=[tvec',Ilinet(nphase+1:2*nphase,:)'];


    y5=t0max;




    if SPS.PowerguiInfo.Discrete
        for imode=1:nphase

            t0mode=long/Smode(imode);
            if t0mode<t0max
                n1=find(tvec==-Ts*ceil(t0mode/Ts));
                if n1>1
                    y1(1:n1-1,imode+1)=0;
                    y2(1:n1-1,imode+1)=0;
                    y3(1:n1-1,imode+1)=0;
                    y4(1:n1-1,imode+1)=0;
                end
            end
        end

    else


        y1=V1;
        y2=V2;
        y3=I1;
        y4=I2;

    end