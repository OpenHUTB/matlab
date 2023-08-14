function[Fxo]=automltirepurelongFx(kappa,Vx,Fz,gamma,LONGVL,...
    FNOMIN,FZMIN,FZMAX,...
    press,NOMPRES,PRESMIN,PRESMAX,...
    PCX1,PDX1,PDX2,PDX3,...
    PEX1,PEX2,PEX3,PEX4,...
    PKX1,PKX2,PKX3,...
    PHX1,PHX2,...
    PVX1,PVX2,...
    PPX1,PPX2,PPX3,PPX4,...
    lam_Fzo,lam_muV,lam_mux,lam_Kxkappa,...
    lam_Cx,lam_Ex,lam_Hx,lam_Vx,...
    zeta)%#codegen
    coder.allowpcode('plain')




    tempInds=Fz<FZMIN;
    Fz(tempInds)=FZMIN(tempInds);
    tempInds=(Fz>FZMAX);
    Fz(tempInds)=FZMAX(tempInds);
    tempInds=press<PRESMIN;
    press(tempInds)=PRESMIN(tempInds);
    tempInds=press>PRESMAX;
    press(tempInds)=PRESMAX(tempInds);
    dpi=(press-NOMPRES)./NOMPRES;
    dfz=(Fz-FNOMIN.*lam_Fzo)./FNOMIN.*lam_Fzo;
    SHx=(PHX1+PHX2.*dfz).*lam_Hx;
    kappa_x=kappa+SHx;

    epsilon_x=0.1;

    Vsx=-abs(Vx).*kappa;
    Vsy=0;
    Vs=sqrt(Vsx.^2+Vsy.^2);
    lam_mux_star=lam_mux./(1+lam_muV.*Vs./LONGVL);
    lam_mux_prime=lam_mux_star.*10./(1+(10-1).*lam_mux_star);
    mu_x=(PDX1+PDX2.*dfz).*(1+PPX3.*dpi+PPX4.*dpi.^2).*(1-PDX3.*gamma.^2).*lam_mux_star;

    Cx=PCX1.*lam_Cx;
    Cx(Cx<0)=0;

    Dx=mu_x.*Fz.*zeta(2,:)';
    Dx(Dx<0)=0;

    Ex=(PEX1+PEX2.*dfz+PEX3.*dfz.^2).*(1-PEX4.*tanh(10.*kappa_x)).*lam_Ex;
    Ex(Ex>1)=1;

    Kxkappa=Fz.*(PKX1+PKX2.*dfz).*exp(PKX3.*dfz).*(1+PPX1.*dpi+PPX2.*dpi.^2).*lam_Kxkappa;

    [CxDxp,~]=automltirediv0prot(Cx.*Dx,epsilon_x);
    Bx=Kxkappa./CxDxp;

    SVx=Fz.*(PVX1+PVX2.*dfz).*lam_mux_prime.*lam_Vx.*zeta(2,:)';

    Fxo=automltiremagic(Dx,Cx,Bx,Ex,kappa_x)+SVx;
end