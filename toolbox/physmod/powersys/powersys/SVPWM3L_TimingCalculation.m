function[TgABC_On,TgABC_Off,Sn]=SVPWM3L_TimingCalculation(Vref,DeltaVdc,Fsw)













%#codegen
    coder.allowpcode('plain');
    TgABC_On=[0,0,0];
    TgABC_Off=[0,0,0];
    DV=DeltaVdc;
    Tsamp=1/Fsw/2;



    if(Vref(1)*Vref(2)*Vref(3)>=0)
        if Vref(1)>=0
            Sn=1;
            a=2;
            b=-1;
        elseif(Vref(2)>=0)
            Sn=3;
            a=-1;
            b=2;
        else
            Sn=5;
            a=-1;
            b=-1;
        end
    elseif(Vref(1)<0)
        Sn=4;
        a=-2;
        b=1;
    elseif(Vref(2)<0)
        Sn=6;
        a=1;
        b=-2;
    else
        Sn=2;
        a=1;
        b=1;
    end
    Vas=Vref(1)/sqrt(3)-a*1/6;
    Vbs=Vref(2)/sqrt(3)-b*1/6;
    Vcs=-Vas-Vbs;


    Tas=2*Vas*Tsamp;
    Tbs=2*Vbs*Tsamp;
    Tcs=2*Vcs*Tsamp;


    if((Tas>Tbs)&&(Tas>Tcs))
        Tmax=Tas;
    elseif((Tbs>Tas)&&(Tbs>Tcs))
        Tmax=Tbs;
    else
        Tmax=Tcs;
    end
    if((Tas<Tbs)&&(Tas<Tcs))
        Tmin=Tas;
    elseif((Tbs<Tas)&&(Tbs<Tcs))
        Tmin=Tbs;
    else
        Tmin=Tcs;
    end
    Teff=Tmax-Tmin;
    T0=Tsamp-Teff;
    Toffset=T0/2*(1-DV)-Tmin;


    Tga=Tas+Toffset;
    Tgb=Tbs+Toffset;
    Tgc=Tcs+Toffset;


    TgABC_On(1)=Tsamp-Tga;
    TgABC_On(2)=Tsamp-Tgb;
    TgABC_On(3)=Tsamp-Tgc;


    TgABC_Off(1)=Tsamp+Tga;
    TgABC_Off(2)=Tsamp+Tgb;
    TgABC_Off(3)=Tsamp+Tgc;



