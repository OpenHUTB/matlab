function[j,a,a2,Vnom,Fnom,Vinjnom,Kp_Vac,Ki_Vac,Kp_Vdc,Ki_Vdc,MagIinit,PhaIinit,R_RL,L_RL,Inom_pu,VconvMax_pu,VconvMaxPrim,m_max,VconvMaxSec,xfo_ratio,K_Vdq2m,Pnom]=SSSCInit(SystemNominal,SeriesNominal,RL,Iinit,VnomDC,Par_VacReg,Par_VdcReg,gcbh)


    j=sqrt(-1);
    a=exp(j*2*pi/3);
    a2=exp(-j*2*pi/3);

    Vnom=SystemNominal(1);
    Fnom=SystemNominal(2);

    Pnom=SeriesNominal(1);
    Vinjnom=SeriesNominal(2);
    Kp_Vac=Par_VacReg(1);
    Ki_Vac=Par_VacReg(2);
    Kp_Vdc=Par_VdcReg(1);
    Ki_Vdc=Par_VdcReg(2);

    MagIinit=Iinit(1);
    PhaIinit=Iinit(2);


    R_RL=(Vinjnom)^2*RL(1);
    L_RL=(Vinjnom)^2*RL(2);





    Inom_pu=1/Vinjnom;
    VconvMax_pu=Vinjnom+Inom_pu*L_RL;
    VconvMaxPrim=Vnom*VconvMax_pu;
    m_max=0.9;
    VconvMaxSec=m_max*sqrt(3)*VnomDC/(2*sqrt(2));

    xfo_ratio=VconvMaxPrim/VconvMaxSec;





    K_Vdq2m=1/Vinjnom*(Vnom*Vinjnom/xfo_ratio)/(VnomDC*sqrt(3)/(2*sqrt(2)));


    SsscCback(gcbh,1);
    power_initmask();

end

