function[Fx,Fy,Fz,Mx,My,Mz,Re,kappa,alpha]=vdyncslamdatire(omega,Vx,Vy,Fz,rho,KPUMIN,KPUMAX,FZMAX,FZMIN,c1,c2,c3,VXLOW,UNLOADED_RADIUS)%#codegen
    coder.allowpcode('plain')




    [Vxp,Vxpabs]=div0protect(Vx,VXLOW);

    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN(tempInds);
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX(tempInds);



    Re=UNLOADED_RADIUS-rho;
    tempInds=Re<1e-3;
    Re(tempInds)=1e-3;



    kappa=(Re.*omega-Vx)./Vxpabs;

    tempInds=(kappa<KPUMIN);
    kappa(tempInds)=KPUMIN(tempInds);
    tempInds=(kappa>KPUMAX);
    kappa(tempInds)=KPUMAX(tempInds);



    alpha=atan(Vy./Vxp).*tanh(4.*Vx);
    tempInds=(alpha<ALPMIN);
    alpha(tempInds)=ALPMIN(tempInds);
    tempInds=(alpha>ALPMAX);
    alpha(tempInds)=ALPMAX(tempInds);









    Vsy=-Vxpabs.*tan(alpha);


    Vcx=Vx;


    Vcy=Vsy;
    Vc=sqrt(Vcx.^2+Vcy.^2);
    [Vcp,~]=div0protect(Vc,VXLOW);



    Vp=Re.*omega-Vx;










    alpha=atan(Vy/Vp);

    lam_x=(Vp-V*cos(alpha))/Vcp;
    lam_y=-V*sin(alpha)/Vcp;
    lam_mag=sqrt(lam_x^2+lam_y^2);

    lam_alpha=atan(abs(lam_x)/max(abs(lam_y),VXTOL));
    mu=-c1*1.1*exp(-c2*abs(lam_mag))-exp(-c3*abs(lam_mag));
    mu_x=mu*sin(lam_alpha);
    mu_y=mu*cos(lam_alpha);

    Fx=Fz.*mu_x./max(abs(lam_x),VXTOL);
    Fy=Fz.*mu_y./max(abs(lam_y),VXTOL);

    Mx=0;
    My=0;
    Mz=0;
