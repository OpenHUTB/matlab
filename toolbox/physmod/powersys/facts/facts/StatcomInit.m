function[j,Fnom,Vnom_SH,VdcRef_SH,R_RL_SH,L_RL_SH,Kp_Vac_SH,Ki_Vac_SH,Kp_Vdc_SH,Ki_Vdc_SH,Kp_I_SH,Ki_I_SH,Kf_I_SH,VconvMax_pu,VconvMaxPrim,m_max,VconvMaxSec,xfo_ratio_SH,K_Vdq2m_SH,a,a2,MagIinit_SH,PhaIinit_SH]=StatcomInit(SystemNominal,VnomDC,Par_VacReg,Par_VdcReg,Par_IReg_SH,Iinit_SH,gcbh,RL_SH)



    j=sqrt(-1);
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
    Kf_I_SH=Par_IReg_SH(3);

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


    StatcomCback(gcbh,1);
    power_initmask();

end

