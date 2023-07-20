function[Ts,WantBlockChoice,Vnom,fnom,P0,Q0,Mag_V0,Pha_V0,V0_d,V0_q,np,nq,Tp1,Tp2,Tq1,Tq2,Vbase,I1_init,Mag_ia,Phase_ia,Vmin,PQext,a]=...
    ThreePhaseDynamicLoadInit(block,NominalVoltage,ActiveReactivePowers,PositiveSequence,NpNq,TimeConstants,MinimumVoltage,ExternalControl)






    power_initmask();
    powericon('ThreePhaseDynamicLoadCback',block);
    powericon('psbloadfunction',block,'gotofrom','Initialize');

    Vnom=NominalVoltage(1);
    fnom=NominalVoltage(2);
    P0=ActiveReactivePowers(1);
    Q0=ActiveReactivePowers(2);
    Mag_V0=PositiveSequence(1);
    Pha_V0=PositiveSequence(2);
    V0_d=Mag_V0*cos(Pha_V0*pi/180);
    V0_q=Mag_V0*sin(Pha_V0*pi/180);
    np=NpNq(1);
    nq=NpNq(2);
    Tp1=TimeConstants(1);
    Tp2=TimeConstants(2);
    Tq1=TimeConstants(3);
    Tq2=TimeConstants(4);
    Vbase=Vnom/sqrt(3)*sqrt(2);


    I1_init=(P0-1i*Q0)/((V0_d-1i*V0_q)*Vnom)/sqrt(3)*sqrt(2);
    Mag_ia=abs(I1_init);
    Phase_ia=angle(I1_init)*180/pi;

    Vmin=MinimumVoltage;
    PQext=ExternalControl;
    a=exp(1i*2*pi/3);

    PowerguiInfo=getPowerguiInfo(bdroot(block),block);
    Ts=PowerguiInfo.Ts;

    if PowerguiInfo.Phasor
        WantBlockChoice='Phasor';
    end
    if PowerguiInfo.DiscretePhasor
        WantBlockChoice='Phasor Discrete';
    end
    if PowerguiInfo.Discrete
        WantBlockChoice='Discrete';
    end
    if PowerguiInfo.Continuous
        WantBlockChoice='Continuous';
    end