function[j,Fnom,Vnom_SH,VdcRef_SH,R_RL_SH,L_RL_SH,Kp_Vac_SH,Ki_Vac_SH,Kp_Vdc_SH,Ki_Vdc_SH,Kp_I_SH,Ki_I_SH,Kf_I_SH,VconvMax_pu,VconvMaxPrim,m_max,VconvMaxSec,xfo_ratio_SH,K_Vdq2m_SH,a,a2,MagIinit_SH,PhaIinit_SH,Pnom_SE,Kp_PReg_SE,Ki_PReg_SE,MagIinit_SE,PhaIinit_SE,xfo_ratio_SE,R_RL_SE,L_RL_SE,K_Vdq2m_SE,Vnom_SE,Vinjnom]=upfcInit(SystemNominal,VnomDC,Par_VacReg,Par_VdcReg,Par_IReg_SH,Iinit_SH,gcbh,RL_SH,Iinit_SE,RL_SE,SeriesNominal,Par_PReg_SE)

    j=sqrt(-1);
    Vnom_SE=SystemNominal(1);
    Fnom=SystemNominal(2);
    Vnom_SH=SystemNominal(1);
    VdcRef_SH=VnomDC;
    R_RL_SH=RL_SH(1);
    L_RL_SH=RL_SH(2);
    Kp_Vac_SH=Par_VacReg(1);
    Ki_Vac_SH=Par_VacReg(2);
    Kp_Vdc_SH=Par_VdcReg(1);
    Ki_Vdc_SH=Par_VdcReg(2);
    Kp_I_SH=Par_IReg_SH(1);
    Ki_I_SH=Par_IReg_SH(2);
    Kf_I_SH=L_RL_SH;

    MagIinit_SH=Iinit_SH(1);
    PhaIinit_SH=Iinit_SH(2);




    VconvMax_pu=1+1*L_RL_SH;
    VconvMaxPrim=Vnom_SH*VconvMax_pu;
    m_max=0.9;
    VconvMaxSec=m_max*sqrt(3)*VnomDC/(2*sqrt(2));

    xfo_ratio_SH=VconvMaxPrim/VconvMaxSec;





    K_Vdq2m_SH=(Vnom_SH/xfo_ratio_SH)/(VnomDC*sqrt(3)/(2*sqrt(2)));

    a=exp(j*2*pi/3);
    a2=exp(-j*2*pi/3);

    Pnom_SE=SeriesNominal(1);
    Vinjnom=SeriesNominal(2);
    Kp_PReg_SE=Par_PReg_SE(1);
    Ki_PReg_SE=Par_PReg_SE(2);

    MagIinit_SE=Iinit_SE(1);
    PhaIinit_SE=Iinit_SE(2);


    R_RL_SE=(Vinjnom)^2*RL_SE(1);
    L_RL_SE=(Vinjnom)^2*RL_SE(2);





    Inom_pu=1/Vinjnom;
    VconvMax_pu=Vinjnom+Inom_pu*L_RL_SE;
    VconvMaxPrim=Vnom_SE*VconvMax_pu;
    m_max=0.9;
    VconvMaxSec=m_max*sqrt(3)*VnomDC/(2*sqrt(2));

    xfo_ratio_SE=VconvMaxPrim/VconvMaxSec;





    K_Vdq2m_SE=1/Vinjnom*(Vnom_SE*Vinjnom/xfo_ratio_SE)/(VnomDC*sqrt(3)/(2*sqrt(2)));


    UpfcCback(gcbh,1);
    power_initmask();



