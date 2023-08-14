function[Ts,WantBlockChoice,PSS]=MBPowerSystemStabilizerInit(block,OperationMode,Kg,GL,GI,GH,GLd,TcLF,GId,TcIF,GHd,TcHF,LIM)






    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;


    WantDiscreteModel=PowerguiInfo.Discrete||PowerguiInfo.DiscretePhasor;
    if WantDiscreteModel
        WantBlockChoice='Discrete';
    else
        WantBlockChoice='Continuous';
    end

    power_initmask();

    MBPowerSystemStabilizerCback(block,'Plot');




    PSS.Kg=Kg;

    if OperationMode==2

        PSS.Detailed=1;
        PSS.Kg=1;

        PSS.KL1=GLd(1);
        PSS.KL2=GLd(:,2);
        PSS.KL=GLd(3);

        PSS.TL1=TcLF(1);
        PSS.TL2=TcLF(2);
        PSS.TL3=TcLF(3);
        PSS.TL4=TcLF(4);
        PSS.TL5=TcLF(5);
        PSS.TL6=TcLF(6);
        PSS.TL7=TcLF(7);
        PSS.TL8=TcLF(8);
        PSS.TL9=TcLF(9);
        PSS.TL10=TcLF(10);
        PSS.TL11=TcLF(11);
        PSS.TL12=TcLF(12);
        PSS.KL11=TcLF(13);
        PSS.KL17=TcLF(14);

        PSS.KI1=GId(1);
        PSS.KI2=GId(:,2);
        PSS.KI=GId(3);

        PSS.TI1=TcIF(1);
        PSS.TI2=TcIF(2);
        PSS.TI3=TcIF(3);
        PSS.TI4=TcIF(4);
        PSS.TI5=TcIF(5);
        PSS.TI6=TcIF(6);
        PSS.TI7=TcIF(7);
        PSS.TI8=TcIF(8);
        PSS.TI9=TcIF(9);
        PSS.TI10=TcIF(10);
        PSS.TI11=TcIF(11);
        PSS.TI12=TcIF(12);

        PSS.KI11=TcIF(13);
        PSS.KI17=TcIF(14);
        PSS.KH1=GHd(1);
        PSS.KH2=GHd(:,2);
        PSS.KH=GHd(3);
        PSS.TH1=TcHF(1);
        PSS.TH2=TcHF(2);
        PSS.TH3=TcHF(3);
        PSS.TH4=TcHF(4);
        PSS.TH5=TcHF(5);
        PSS.TH6=TcHF(6);
        PSS.TH7=TcHF(7);
        PSS.TH8=TcHF(8);
        PSS.TH9=TcHF(9);
        PSS.TH10=TcHF(10);
        PSS.TH11=TcHF(11);
        PSS.TH12=TcHF(12);
        PSS.KH11=TcHF(13);
        PSS.KH17=TcHF(14);
    else
        PSS.Detailed=0;

        R=1.2;
        K=(R*R+R)/(R*R-2*R+1);
        PSS.KL1=K;
        PSS.KL2=K;
        PSS.KI1=K;
        PSS.KI2=K;
        PSS.KH1=K;
        PSS.KH2=K;
        PSS.TL2=1/(2*pi*GL(1)*sqrt(R));
        PSS.KL=GL(2);
        PSS.TL1=PSS.TL2/R;
        PSS.TL7=PSS.TL2;
        PSS.TL8=PSS.TL7*R;

        PSS.TI2=1/(2*pi*GI(1)*sqrt(R));
        PSS.KI=GI(2);
        PSS.TI1=PSS.TI2/R;
        PSS.TI7=PSS.TI2;
        PSS.TI8=PSS.TI7*R;
        PSS.TH2=1/(2*pi*GH(1)*sqrt(R));
        PSS.KH=GH(2);
        PSS.TH1=PSS.TH2/R;
        PSS.TH7=PSS.TH2;
        PSS.TH8=PSS.TH7*R;

        PSS.TL3=0;
        PSS.TL4=0;
        PSS.TL5=0;
        PSS.TL6=0;
        PSS.TL9=0;
        PSS.TL10=0;
        PSS.TL11=0;
        PSS.TL12=0;
        PSS.TI3=0;
        PSS.TI4=0;
        PSS.TI5=0;
        PSS.TI6=0;
        PSS.TI9=0;
        PSS.TI10=0;
        PSS.TI11=0;
        PSS.TI12=0;
        PSS.TH3=0;
        PSS.TH4=0;
        PSS.TH5=0;
        PSS.TH6=0;
        PSS.TH9=0;
        PSS.TH10=0;
        PSS.TH11=0;
        PSS.TH12=0;
        PSS.KL11=1;
        PSS.KL17=1;
        PSS.KI11=1;
        PSS.KI17=1;
        PSS.KH11=1;
        PSS.KH17=1;
    end

    PSS.LIM_VL=LIM(1);
    PSS.LIM_VI=LIM(2);
    PSS.LIM_VH=LIM(3);
    PSS.LIM_VS=LIM(4);