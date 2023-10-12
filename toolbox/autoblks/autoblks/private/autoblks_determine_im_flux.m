function[Isd_0,Isq_0,Tem]=autoblks_determine_im_flux(PolePairs,Rs,Lls,Rr,Llr,Lm,Frate,Vrate,Srate)

    f=Frate;VLLrms=Vrate;s=Srate;
    Wsyn=2*pi*f;
    Wm=(1-s)*Wsyn;%#ok<*NASGU> % rotor speed in electrical rad/s

    Va=VLLrms*sqrt(2)/sqrt(3);

    Vs_0=(3/2)*Va;
    Theta_Vs_0=0;

    Theta_da_0=0;
    Vsd_0=sqrt(2/3)*Vs_0*cos(Theta_Vs_0-Theta_da_0);
    Vsq_0=sqrt(2/3)*Vs_0*sin(Theta_Vs_0-Theta_da_0);

    Ls=Lls+Lm;
    Lr=Llr+Lm;
    tau_r=Lr/Rr;

    A=[Rs,-Wsyn*Ls,0,-Wsyn*Lm;...
    Wsyn*Ls,Rs,Wsyn*Lm,0;...
    0,-s*Wsyn*Lm,Rr,-s*Wsyn*Lr;...
    s*Wsyn*Lm,0,s*Wsyn*Lr,Rr];

    V_dq_0=[Vsd_0;Vsq_0;0;0];
    I_dq_0=A\V_dq_0;
    Isd_0=I_dq_0(1);
    Isq_0=I_dq_0(2);
    Ird_0=I_dq_0(3);
    Irq_0=I_dq_0(4);
    Tem=(PolePairs)*Lm*(Isq_0*Ird_0-Isd_0*Irq_0);

    M=[Ls,0,Lm,0;...
    0,Ls,0,Lm;...
    Lm,0,Lr,0;...
    0,Lm,0,Lr];

    fl_dq_0=M*[Isd_0;Isq_0;Ird_0;Irq_0];
    fl_sd_0=fl_dq_0(1);
    fl_sq_0=fl_dq_0(2);
    fl_rd_0=fl_dq_0(3);
    fl_rq_0=fl_dq_0(4);
    [thetar,fl_r_dq_0]=cart2pol(fl_rd_0,fl_rq_0);
    [thetas,fl_s_dq_0]=cart2pol(fl_sd_0,fl_sq_0);
    [thetaIs,Is_0]=cart2pol(Isd_0,Isq_0);

    fl_rq_0=0;
    fl_rd_0=fl_r_dq_0;
    [fl_sd_0,fl_sq_0]=pol2cart(thetas-thetar,fl_s_dq_0);%#ok<*ASGLU>
    [Isd_0,Isq_0]=pol2cart(thetaIs-thetar,Is_0);

end

